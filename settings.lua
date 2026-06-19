-- Data stage: registers doodle-* setting prototypes (runtime reads in scripts/setting_values.lua).

local ColorPresets = require("color_presets")

data:extend({
  {
    type = "int-setting",
    name = "doodle-undo-stack-cap",
    setting_type = "runtime-global",
    default_value = 50,
    minimum_value = 5,
    maximum_value = 200,
    order = "a"
  },
  {
    type = "int-setting",
    name = "doodle-min-line-width",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 50,
    order = "b-a"
  },
  {
    type = "int-setting",
    name = "doodle-max-line-width",
    setting_type = "startup",
    default_value = 100,
    minimum_value = 5,
    maximum_value = 200,
    order = "b-b"
  },
  {
    type = "int-setting",
    name = "doodle-line-width-step",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 25,
    order = "b-c"
  },
  {
    type = "string-setting",
    name = "doodle-line-color",
    setting_type = "runtime-per-user",
    default_value = ColorPresets.default_id,
    allowed_values = ColorPresets.ids(),
    order = "c"
  }
})
