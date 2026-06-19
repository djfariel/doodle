local Actions = require("scripts.actions")
local Constants = require("scripts.constants")
local Geometry = require("scripts.geometry")
local Preview = require("scripts.preview")
local TwoClickTool = require("scripts.tools.two_click_tool")

return TwoClickTool.build({
  tool_id = Constants.TOOL_SQUARE,
  action_id = Constants.ACTION_SQUARE_TOOL,
  order = "0102",
  locale_key = "square-tool",
  cursor_item = Constants.CURSOR_SQUARE,
  begin_in_progress = function(position, surface_index)
    return {
      tool_id = Constants.TOOL_SQUARE,
      corner_a = position,
      surface_index = surface_index
    }
  end,
  redraw_preview = function(preview, surface, in_progress, style, audience)
    Preview.redraw_rect(preview, surface, in_progress.corner_a, in_progress.corner_b, style, audience)
  end,
  commit = function(player, in_progress, position, surface)
    local corners = Geometry.normalize_rect_corners(in_progress.corner_a, position)
    return Actions.create_rectangle(player, corners.left_top, corners.right_bottom, surface)
  end,
  committed_message = { "doodle-message.square-committed" }
})
