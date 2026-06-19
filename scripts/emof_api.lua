-- EMOF integration entry point. Load order: action_dispatch -> input -> tool_router -> tools;
-- see README architecture notes.

local Constants = require("scripts.constants")
local ActionDispatch = require("scripts.action_dispatch")
local EmofStatus = require("scripts.emof_status")
local ToolRouter = require("scripts.tool_router")

local M = {}

function M.available()
  return EmofStatus.available()
end

function M.failure_reason()
  return EmofStatus.failure_reason()
end

function M.notify_player(player)
  EmofStatus.notify_player(player)
end

function M.notify_all_players()
  EmofStatus.notify_all_players()
end

function M.register_map_tool_interface()
  remote.add_interface(Constants.MAP_TOOL_INTERFACE, {
    on_map_tool_click = function(payload)
      return ToolRouter.on_map_tool_click(payload)
    end,
    on_map_tool_cancel = function(payload)
      ToolRouter.on_map_tool_cancel(payload)
    end
  })
end

function M.register_events()
  EmofStatus.reset()

  local action_proto = prototypes.custom_event[Constants.EMOF_ACTION_CLICKED_EVENT]
  if not (action_proto and action_proto.valid) then
    EmofStatus.fail(
      Constants.EMOF_ACTION_CLICKED_EVENT,
      "Extensible Map Overlay Framework is missing or outdated (custom event: "
        .. Constants.EMOF_ACTION_CLICKED_EVENT
        .. ")."
    )
    return false
  end

  local tool_state_proto = prototypes.custom_event[Constants.EMOF_TOOL_STATE_CHANGED_EVENT]
  if not (tool_state_proto and tool_state_proto.valid) then
    EmofStatus.fail(
      Constants.EMOF_TOOL_STATE_CHANGED_EVENT,
      "Extensible Map Overlay Framework is missing or outdated (custom event: "
        .. Constants.EMOF_TOOL_STATE_CHANGED_EVENT
        .. ")."
    )
    return false
  end

  script.on_event(Constants.EMOF_ACTION_CLICKED_EVENT, ActionDispatch.on_action_clicked)

  script.on_event(Constants.EMOF_TOOL_STATE_CHANGED_EVENT, function(event)
    ToolRouter.on_tool_state_changed(event)
  end)

  return true
end

function M.register_map_tools()
  if not EmofStatus.available() then
    return false
  end

  local ok, reason = ToolRouter.register_map_tools()
  if not ok then
    EmofStatus.fail(reason, "Map tool registration failed: " .. reason)
    return false
  end

  return true
end

return M
