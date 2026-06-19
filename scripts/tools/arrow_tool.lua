local Actions = require("scripts.actions")
local Constants = require("scripts.constants")
local Preview = require("scripts.preview")
local TwoClickTool = require("scripts.tools.two_click_tool")

return TwoClickTool.build({
  tool_id = Constants.TOOL_ARROW,
  action_id = Constants.ACTION_ARROW_TOOL,
  order = "0101",
  locale_key = "arrow-tool",
  cursor_item = Constants.CURSOR_ARROW,
  begin_in_progress = function(position, surface_index)
    return {
      tool_id = Constants.TOOL_ARROW,
      from = position,
      surface_index = surface_index
    }
  end,
  redraw_preview = function(preview, surface, in_progress, style, audience)
    Preview.redraw_segment(preview, surface, in_progress.from, in_progress.to, style, audience)
  end,
  commit = function(player, in_progress, position, surface)
    return Actions.create_arrow(player, in_progress.from, position, surface)
  end,
  committed_message = { "doodle-message.arrow-committed" }
})
