local Constants = require("scripts.constants")
local Gui = require("scripts.gui")
local Polyline = require("scripts.polyline")
local PlayerState = require("scripts.player_state")
local ToolUtil = require("scripts.tools.tool_util")

local M = {}

local GUI = Constants.GUI

M.tool_id = Constants.TOOL_LINE
M.action_id = Constants.ACTION_LINE_TOOL

function M.map_tool_spec()
  return ToolUtil.base_map_tool_spec(M.tool_id, "0100", "line-tool", Constants.CURSOR_LINE)
end

function M.is_active(state)
  return state.active_tool_id == M.tool_id
end

function M.activate(player, surface_index)
  ToolUtil.activate_tool(player, surface_index, M.tool_id)
end

local function redraw_preview(player, state)
  Polyline.redraw_preview(player, state)
end

function M.deactivate(player, reason)
  ToolUtil.deactivate_tool(player, M.tool_id, reason, {
    on_cancel_in_progress = Polyline.cancel
  })
end

function M.on_map_click(event)
  local player = game.get_player(event.player_index)
  if not player then
    return "continue"
  end

  local state = PlayerState.get_player(player.index)
  if not M.is_active(state) then
    return "continue"
  end

  local position, surface = ToolUtil.resolve_click(player, event)
  if not position then
    return "continue"
  end

  if event.surface_index then
    state.tool_surface_index = event.surface_index
  end

  Polyline.append_point(player, state, position, surface)
  Gui.update(player)
  return "continue"
end

function M.on_style_changed(player, state)
  redraw_preview(player, state)
end

function M.handle_toolbar_control(player, control_name, event)
  if control_name == GUI.width_slider then
    local state = PlayerState.get_player(player.index)
    ToolUtil.handle_width_slider(player, state, redraw_preview, event.element.slider_value)
    return true
  end

  if control_name == GUI.finish_button then
    if Polyline.try_finish(player) then
      Gui.update(player)
    end
    return true
  end

  if control_name == GUI.cancel_button then
    return "cancel_tool", Constants.DEACTIVATE_REASON.line_cancelled
  end

  return false
end

return M
