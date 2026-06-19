local Constants = require("scripts.constants")

local function tool_action(name, order, locale_key, sprite, tool_id)
  return {
    type = "mod-data",
    name = name,
    data_type = "emof.map-action-button",
    order = order,
    localised_name = { "doodle-gui." .. locale_key },
    localised_description = { "doodle-gui." .. locale_key .. "-tooltip" },
    data = {
      owning_mod = Constants.OWNER,
      size = "half",
      sprite = sprite,
      tool_id = tool_id,
      tool_start = "immediate"
    }
  }
end

data:extend({
  tool_action(Constants.ACTION_LINE_TOOL, "0100", "line-tool", "doodle-line-tool-icon", Constants.TOOL_LINE),
  tool_action(Constants.ACTION_ARROW_TOOL, "0101", "arrow-tool", "doodle-arrow-tool-icon", Constants.TOOL_ARROW),
  tool_action(Constants.ACTION_SQUARE_TOOL, "0102", "square-tool", "doodle-square-tool-icon", Constants.TOOL_SQUARE),
  tool_action(Constants.ACTION_CIRCLE_TOOL, "0103", "circle-tool", "doodle-circle-tool-icon", Constants.TOOL_CIRCLE),
  tool_action(Constants.ACTION_ERASER_TOOL, "0104", "eraser-tool", "doodle-eraser-tool-icon", Constants.TOOL_ERASER)
})
