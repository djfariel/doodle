local emof_cursor_item = require("__extensible-map-overlay-framework__/prototypes/emof-cursor-item")
local Constants = require("scripts.constants")

local function cursor_item(name, locale_key, icon_filename, order)
  return emof_cursor_item.build({
    name = name,
    localised_name = { "item-name." .. locale_key },
    icon = "__doodle__/graphics/" .. icon_filename,
    icon_size = 64,
    order = order
  })
end

data:extend({
  cursor_item(Constants.CURSOR_LINE, "doodle-line-cursor", "emof-line-tool-icon.png", "d[doodle]-a[line]"),
  cursor_item(Constants.CURSOR_ARROW, "doodle-arrow-cursor", "emof-arrow-tool-icon.png", "d[doodle]-b[arrow]"),
  cursor_item(Constants.CURSOR_SQUARE, "doodle-square-cursor", "emof-square-tool-icon.png", "d[doodle]-c[square]"),
  cursor_item(Constants.CURSOR_CIRCLE, "doodle-circle-cursor", "emof-circle-tool-icon.png", "d[doodle]-d[circle]"),
  cursor_item(Constants.CURSOR_ERASER, "doodle-eraser-cursor", "emof-eraser-tool-icon.png", "d[doodle]-e[eraser]")
})
