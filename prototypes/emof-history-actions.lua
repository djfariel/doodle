local Constants = require("scripts.constants")

data:extend({
  {
    type = "sprite",
    name = "doodle-undo",
    filename = "__base__/graphics/icons/shortcut-toolbar/mip/undo-x24.png",
    priority = "extra-high-no-scale",
    size = 24,
    flags = { "gui-icon" },
    mipmap_count = 2
  },
  {
    type = "sprite",
    name = "doodle-redo",
    filename = "__base__/graphics/icons/shortcut-toolbar/mip/redo-x24.png",
    priority = "extra-high-no-scale",
    size = 24,
    flags = { "gui-icon" },
    mipmap_count = 2
  },
  {
    type = "mod-data",
    name = Constants.ACTION_UNDO,
    data_type = "emof.map-action-button",
    order = "0106",
    localised_name = { "doodle-gui.undo-doodle" },
    localised_description = { "doodle-gui.undo-doodle-tooltip" },
    data = {
      owning_mod = Constants.OWNER,
      size = "half",
      sprite = "doodle-undo",
      enabled = {
        interface = Constants.MAP_ACTIONS_INTERFACE,
        function_name = "is_undo_enabled"
      }
    }
  },
  {
    type = "mod-data",
    name = Constants.ACTION_REDO,
    data_type = "emof.map-action-button",
    order = "0107",
    localised_name = { "doodle-gui.redo-doodle" },
    localised_description = { "doodle-gui.redo-doodle-tooltip" },
    data = {
      owning_mod = Constants.OWNER,
      size = "half",
      sprite = "doodle-redo",
      enabled = {
        interface = Constants.MAP_ACTIONS_INTERFACE,
        function_name = "is_redo_enabled"
      }
    }
  }
})
