local Actions = require("scripts.actions")
local Constants = require("scripts.constants")
local Geometry = require("scripts.geometry")
local Preview = require("scripts.preview")
local TwoClickTool = require("scripts.tools.two_click_tool")

return TwoClickTool.build({
  tool_id = Constants.TOOL_CIRCLE,
  action_id = Constants.ACTION_CIRCLE_TOOL,
  order = "0103",
  locale_key = "circle-tool",
  cursor_item = Constants.CURSOR_CIRCLE,
  begin_in_progress = function(position, surface_index)
    return {
      tool_id = Constants.TOOL_CIRCLE,
      center = position,
      surface_index = surface_index
    }
  end,
  redraw_preview = function(preview, surface, in_progress, style, audience)
    Preview.redraw_circle(preview, surface, in_progress.center, in_progress.edge, style, audience)
  end,
  validate_commit = function(player, in_progress, position)
    local radius = Geometry.distance(in_progress.center, position)
    if radius < Constants.MIN_CIRCLE_RADIUS then
      player.print({ "doodle-message.circle-too-small" })
      return false
    end
    return true
  end,
  commit = function(player, in_progress, position, surface)
    local radius = Geometry.distance(in_progress.center, position)
    return Actions.create_circle(player, in_progress.center, radius, surface)
  end,
  committed_message = { "doodle-message.circle-committed" }
})
