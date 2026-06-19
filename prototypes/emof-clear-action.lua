local Constants = require("scripts.constants")

data:extend({
  {
    type = "mod-data",
    name = Constants.ACTION_CLEAR_ALL,
    data_type = "emof.map-action-button",
    order = "0105",
    localised_name = { "doodle-gui.clear-button" },
    localised_description = { "doodle-gui.clear-tooltip" },
    data = {
      owning_mod = Constants.OWNER,
      size = "half",
      sprite = "utility/trash"
    }
  }
})
