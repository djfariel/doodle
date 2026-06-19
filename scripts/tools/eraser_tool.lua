local Actions = require("scripts.actions")
local Constants = require("scripts.constants")
local HitTest = require("scripts.hit_test")
local PlayerState = require("scripts.player_state")
local ToolUtil = require("scripts.tools.tool_util")

local M = {}

M.tool_id = Constants.TOOL_ERASER
M.action_id = Constants.ACTION_ERASER_TOOL

function M.map_tool_spec()
  return ToolUtil.base_map_tool_spec(M.tool_id, "0104", "eraser-tool", Constants.CURSOR_ERASER)
end

function M.is_active(state)
  return state.active_tool_id == M.tool_id
end

function M.activate(player, surface_index)
  ToolUtil.activate_tool(player, surface_index, M.tool_id)
end

function M.deactivate(player, reason)
  ToolUtil.deactivate_tool(player, M.tool_id, reason)
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

  local doodle = HitTest.find_nearest_owned(player, surface.index, position)
  if doodle then
    if Actions.delete_owned(player, doodle.id) then
      player.print({ "doodle-message.eraser-deleted" })
    end
  end

  return "continue"
end

return M
