local Constants = require("scripts.constants")
local EmofRefresh = require("scripts.emof_refresh")
local ArrowTool = require("scripts.tools.arrow_tool")
local CircleTool = require("scripts.tools.circle_tool")
local EraserTool = require("scripts.tools.eraser_tool")
local Gui = require("scripts.gui")
local LineTool = require("scripts.tools.line_tool")
local SquareTool = require("scripts.tools.square_tool")
local PlayerState = require("scripts.player_state")
local SettingValues = require("scripts.setting_values")

-- Register new drawing tools in TOOLS and ACTION_TOOLS.
-- Each tool module should expose: tool_id, action_id, map_tool_spec, activate,
-- deactivate, is_active, on_map_click, and optionally handle_toolbar_control.

local M = {}

local REASON = Constants.DEACTIVATE_REASON

local TOOL_LIST = {
  LineTool,
  ArrowTool,
  SquareTool,
  CircleTool,
  EraserTool
}

local TOOLS = {}
local ACTION_TOOLS = {}

for _, tool in ipairs(TOOL_LIST) do
  TOOLS[tool.tool_id] = tool
  ACTION_TOOLS[tool.action_id] = tool
end

local function tool_by_id(tool_id)
  return tool_id and TOOLS[tool_id] or nil
end

function M.cancel_tool(player, tool_id, reason)
  local cancelled = EmofRefresh.call("cancel_map_tool", player.index, reason or REASON.doodle_cancel)
  if not cancelled then
    local tool = tool_by_id(tool_id)
    if tool then
      tool.deactivate(player, reason)
    end
  end
  return cancelled
end

function M.register_map_tools()
  local errors = {}

  for _, tool in ipairs(TOOL_LIST) do
    EmofRefresh.call("unregister", Constants.OWNER, tool.tool_id, "tool")

    local result = EmofRefresh.call("try_register_map_tool", tool.map_tool_spec())
    if not (result and result.ok) then
      errors[#errors + 1] = tool.tool_id
        .. ": "
        .. tostring(result and result.error or "Extensible Map Overlay Framework unavailable")
    end
  end

  if #errors > 0 then
    return false, table.concat(errors, "; ")
  end

  return true
end

function M.on_tool_action_clicked(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then
    return false
  end

  local tool = ACTION_TOOLS[event.id]
  if not tool then
    return false
  end

  tool.activate(player, event.surface_index)
  return true
end

function M.on_map_tool_click(payload)
  local tool = tool_by_id(payload.id)
  if tool and tool.on_map_click then
    return tool.on_map_click(payload)
  end

  return "done"
end

function M.on_map_tool_cancel(_payload)
  -- EMOF requires an on_cancel remote handler on the map tool spec, but Doodle
  -- tears down tools from emof-on-tool-state-changed instead. This stub exists
  -- only to satisfy registration; it is intentionally empty.
end

function M.on_tool_state_changed(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then
    return
  end

  if event.cancelled_tool_id then
    local tool = tool_by_id(event.cancelled_tool_id)
    if not tool then
      EmofRefresh.refresh_chart_controls(player)
      return
    end

    local state = PlayerState.get_player(player.index)
    if state and (tool.is_active(state) or state.in_progress) then
      tool.deactivate(player, event.reason or REASON.tool_ended)
    end
  end

  EmofRefresh.refresh_chart_controls(player)
end

function M.on_line_color_changed(player)
  local state = PlayerState.get_player(player.index)
  SettingValues.sync_style_color(player, state)

  local tool = state.active_tool_id and tool_by_id(state.active_tool_id) or nil
  if tool and tool.on_style_changed then
    tool.on_style_changed(player, state)
  end

  Gui.update(player)
end

function M.handle_toolbar_control(player, control_name, event)
  local state = PlayerState.get_player(player.index)
  local tool = state.active_tool_id and tool_by_id(state.active_tool_id) or nil
  if not tool or not tool.handle_toolbar_control then
    return false
  end

  local handled, cancel_reason = tool.handle_toolbar_control(player, control_name, event)
  if handled == "cancel_tool" and cancel_reason then
    M.cancel_tool(player, tool.tool_id, cancel_reason)
    return true
  end

  return handled == true
end

return M
