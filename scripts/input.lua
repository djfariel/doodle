local Constants = require("scripts.constants")
local Actions = require("scripts.actions")
local EmofStatus = require("scripts.emof_status")
local EmofRefresh = require("scripts.emof_refresh")
local Gui = require("scripts.gui")
local PlayerState = require("scripts.player_state")
local Preview = require("scripts.preview")
local RenderService = require("scripts.render_service")
local Repository = require("scripts.repository")
local SettingValues = require("scripts.setting_values")
local ToolRouter = require("scripts.tool_router")
local UndoService = require("scripts.undo_service")
local Util = require("scripts.util")

local M = {}

local GUI = Constants.GUI
local REASON = Constants.DEACTIVATE_REASON

function M.reset_extension_ui(player)
  local state = PlayerState.get_player(player.index)
  local needs_update = state.clear_confirm_open or state.clear_surface_index

  state.clear_confirm_open = false
  state.clear_surface_index = nil

  if needs_update then
    Gui.update(player)
  end
end

function M.on_action_clicked(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then
    return
  end

  if event.id == Constants.ACTION_CLEAR_ALL then
    M.on_clear_action_clicked(player, event.surface_index)
  elseif event.id == Constants.ACTION_UNDO then
    M.on_undo(player)
  elseif event.id == Constants.ACTION_REDO then
    M.on_redo(player)
  end
end

function M.on_clear_action_clicked(player, surface_index)
  local state = PlayerState.get_player(player.index)
  if state.active_tool_id then
    ToolRouter.cancel_tool(player, state.active_tool_id, REASON.clear_action)
  end
  state.clear_confirm_open = true
  state.clear_surface_index = surface_index or Util.fallback_surface_index(player)
  Gui.update(player)
end

function M.on_chart_controls_closed(player)
  local state = PlayerState.get_player(player.index)
  if state.active_tool_id then
    ToolRouter.cancel_tool(player, state.active_tool_id, REASON.chart_controls_closed)
  end
  M.reset_extension_ui(player)
end

function M.on_undo(player)
  if UndoService.undo(player) then
    player.print({ "doodle-message.undo" })
  else
    player.print({ "doodle-message.undo-empty" })
  end
  EmofRefresh.refresh_chart_controls(player)
  Gui.update(player)
end

function M.on_redo(player)
  if UndoService.redo(player) then
    player.print({ "doodle-message.redo" })
  else
    player.print({ "doodle-message.redo-empty" })
  end
  EmofRefresh.refresh_chart_controls(player)
  Gui.update(player)
end

function M.on_toolbar_control(event, control_name)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if ToolRouter.handle_toolbar_control(player, control_name, event) then
    return
  end

  local state = PlayerState.get_player(player.index)

  if control_name == GUI.clear_confirm_button then
    local surface_index = state.clear_surface_index or state.tool_surface_index or Util.fallback_surface_index(player)
    local snapshots = Actions.clear_owned_for_player(player, surface_index)
    state.clear_confirm_open = false
    state.clear_surface_index = nil
    player.print({ "doodle-message.clear-complete", #snapshots })
    Gui.update(player)
  elseif control_name == GUI.clear_cancel_button then
    state.clear_confirm_open = false
    state.clear_surface_index = nil
    Gui.update(player)
  end
end

function M.on_gui_selection_state_changed(event, control_name)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if control_name ~= GUI.color_dropdown then
    return
  end

  local color_value = Gui.color_from_dropdown_index(event.element.selected_index)
  if not color_value then
    return
  end

  SettingValues.set_line_color_setting(player, color_value)
  ToolRouter.on_line_color_changed(player)
end

function M.on_runtime_mod_setting_changed(event)
  if event.setting_type == "runtime-per-user" and event.setting == "doodle-line-color" then
    local player = game.get_player(event.player_index)
    if player then
      ToolRouter.on_line_color_changed(player)
    end
    return
  end

  if event.setting_type == "runtime-global" and event.setting == "doodle-undo-stack-cap" then
    UndoService.apply_stack_cap_all()
  end
end

function M.on_player_joined_game(player)
  if not (player and player.valid) then
    return
  end

  EmofStatus.notify_player(player)
  RenderService.repair_for_player(player)

  local state = PlayerState.get_player(player.index)
  if state.active_tool_id or state.in_progress or state.clear_confirm_open then
    Preview.destroy(state.preview)
    state.preview = Preview.create()
    state.in_progress = nil
    state.active_tool_id = nil
    state.tool_surface_index = nil
    state.clear_confirm_open = false
    state.clear_surface_index = nil
    Gui.update(player)
  end
end

function M.on_player_left_game(event)
  local player = game.get_player(event.player_index)
  if player and player.valid then
    local state = PlayerState.get_player(player.index)
    if state and state.active_tool_id then
      ToolRouter.cancel_tool(player, state.active_tool_id, REASON.disconnect)
    end
  end

  PlayerState.mark_player_leaving(event.player_index)
  PlayerState.remove_player(event.player_index)
end

function M.on_player_changed_force(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  local state = PlayerState.get_player(player.index)
  if state and state.active_tool_id then
    ToolRouter.cancel_tool(player, state.active_tool_id, REASON.force_changed)
  end

  local cleared = Repository.purge_all_owned_for_player(player)
  UndoService.clear_history(player)
  if cleared > 0 then
    player.print({ "doodle-message.force-changed-cleared", cleared })
  end
  Gui.update(player)
  EmofRefresh.refresh_chart_controls(player)
end

return M
