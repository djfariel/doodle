local Input = require("scripts.input")
local ToolRouter = require("scripts.tool_router")

local M = {}

function M.on_action_clicked(event)
  if not ToolRouter.on_tool_action_clicked(event) then
    Input.on_action_clicked(event)
  end
end

return M
