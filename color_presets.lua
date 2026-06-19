--- Single source of truth for doodle line color presets.
--- When adding a preset:
---   1. Add an entry to `presets` below (id + color; omit color for "player").
---   2. Add matching locale lines in locale/en/config.cfg:
---        [mod-setting-value] doodle-line-color-<id>=...
local M = {}

M.presets = {
  { id = "player" },
  { id = "white", color = { r = 1, g = 1, b = 1, a = 1 } },
  { id = "black", color = { r = 0.15, g = 0.15, b = 0.15, a = 1 } },
  { id = "red", color = { r = 1, g = 0.2, b = 0.2, a = 1 } },
  { id = "green", color = { r = 0.2, g = 0.9, b = 0.2, a = 1 } },
  { id = "blue", color = { r = 0.3, g = 0.5, b = 1, a = 1 } },
  { id = "yellow", color = { r = 1, g = 0.95, b = 0.2, a = 1 } },
  { id = "cyan", color = { r = 0.2, g = 0.95, b = 0.95, a = 1 } },
  { id = "magenta", color = { r = 1, g = 0.2, b = 0.95, a = 1 } },
  { id = "orange", color = { r = 1, g = 0.55, b = 0.1, a = 1 } }
}

M.default_id = M.presets[1].id

function M.ids()
  local result = {}

  for _, preset in ipairs(M.presets) do
    result[#result + 1] = preset.id
  end

  return result
end

function M.preset_color(id)
  for _, preset in ipairs(M.presets) do
    if preset.id == id then
      return preset.color
    end
  end

  return nil
end

function M.locale_key(id)
  return "mod-setting-value.doodle-line-color-" .. id
end

return M
