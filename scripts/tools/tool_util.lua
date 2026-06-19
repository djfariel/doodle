-- Shared tool helpers for drawing tools.

local Constants = require("scripts.constants")
local Gui = require("scripts.gui")
local SettingValues = require("scripts.setting_values")
local Preview = require("scripts.preview")
local PlayerState = require("scripts.player_state")
local Util = require("scripts.util")

local M = {}

M.SILENT_DEACTIVATE_REASONS = {
  [Constants.DEACTIVATE_REASON.toolbar_toggle] = true,
  [Constants.DEACTIVATE_REASON.line_cancelled] = true,
  [Constants.DEACTIVATE_REASON.chart_controls_closed] = true,
  [Constants.DEACTIVATE_REASON.tool_ended] = true,
  [Constants.DEACTIVATE_REASON.clear_action] = true,
  [Constants.DEACTIVATE_REASON.disconnect] = true,
  [Constants.DEACTIVATE_REASON.force_changed] = true
}

function M.base_map_tool_spec(tool_id, order, locale_key, cursor_item)
  return {
    id = tool_id,
    owning_mod = Constants.OWNER,
    order = order,
    caption = { "doodle-gui." .. locale_key },
    tooltip = { "doodle-gui." .. locale_key .. "-tooltip" },
    cursor_item = cursor_item,
    on_click = {
      interface = Constants.MAP_TOOL_INTERFACE,
      function_name = "on_map_tool_click"
    },
    on_cancel = {
      interface = Constants.MAP_TOOL_INTERFACE,
      function_name = "on_map_tool_cancel"
    }
  }
end

function M.activate_tool(player, surface_index, tool_id)
  local state = PlayerState.get_player(player.index)
  local tool_surface_index = surface_index or Util.fallback_surface_index(player)

  state.active_tool_id = tool_id
  state.clear_confirm_open = false
  state.clear_surface_index = nil
  state.tool_surface_index = tool_surface_index
  SettingValues.sync_style_color(player, state)
  Gui.update(player)
  player.print({ "doodle-message.ui-opened" })
end

function M.clear_in_progress(state)
  Preview.destroy(state.preview)
  state.in_progress = nil
end

function M.deactivate_tool(player, tool_id, reason, options)
  options = options or {}

  if PlayerState.is_player_leaving(player.index) then
    return
  end

  local state = PlayerState.get_player(player.index)
  local owns_in_progress = state.in_progress and state.in_progress.tool_id == tool_id
  if not state or (state.active_tool_id ~= tool_id and not owns_in_progress) then
    return
  end

  local cancel_in_progress = reason ~= Constants.DEACTIVATE_REASON.toolbar_toggle

  if state.in_progress and state.in_progress.tool_id == tool_id then
    if cancel_in_progress and options.on_cancel_in_progress then
      options.on_cancel_in_progress(player, state)
    else
      M.clear_in_progress(state)
    end
  end

  state.active_tool_id = nil
  if reason ~= Constants.DEACTIVATE_REASON.clear_action then
    state.clear_confirm_open = false
    state.clear_surface_index = nil
  end
  state.tool_surface_index = nil
  Gui.update(player)

  if cancel_in_progress and not M.SILENT_DEACTIVATE_REASONS[reason] then
    player.print({ "doodle-message.ui-closed" })
  end
end

function M.resolve_click(player, event)
  local position = event.cursor_position and Util.copy_position(event.cursor_position) or nil
  local surface = nil

  if event.surface_index then
    surface = game.surfaces[event.surface_index]
  end

  if not (position and surface and surface.valid) then
    if player and player.valid then
      player.print({ "doodle-message.no-position" })
    end
    return nil, nil
  end

  return position, surface
end

function M.same_surface_or_warn(player, in_progress, surface)
  if in_progress.surface_index == surface.index then
    return true
  end

  player.print({ "doodle-message.surface-changed" })
  return false
end

function M.set_line_width(player, state, redraw_preview_fn, width)
  state.style.width = SettingValues.clamp_line_width(width)
  if state.in_progress and redraw_preview_fn then
    redraw_preview_fn(player, state)
  end
  Gui.update(player)
end

function M.handle_width_slider(player, state, redraw_preview_fn, slider_value)
  M.set_line_width(player, state, redraw_preview_fn, Gui.width_from_slider_value(slider_value))
end

return M
