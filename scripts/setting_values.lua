-- Control stage: reads Factorio global `settings` and builds derived options
-- (width slider, colors). Prototypes are registered in root settings.lua.

local Util = require("scripts.util")
local ColorPresets = require("color_presets")

local M = {}

local FALLBACK_LINE_WIDTH = 10

local width_options = { FALLBACK_LINE_WIDTH }

function M.refresh()
  local min_width = settings.startup["doodle-min-line-width"].value
  local max_width = settings.startup["doodle-max-line-width"].value
  local step = settings.startup["doodle-line-width-step"].value

  if min_width > max_width then
    min_width, max_width = max_width, min_width
  end

  local options = {}
  for width = min_width, max_width, step do
    options[#options + 1] = width
  end

  width_options = #options > 0 and options or { FALLBACK_LINE_WIDTH }
end

function M.width_options()
  return width_options
end

function M.default_line_width()
  for _, width in ipairs(width_options) do
    if width >= FALLBACK_LINE_WIDTH then
      return width
    end
  end

  return width_options[1]
end

function M.clamp_line_width(width)
  local closest = width_options[1]
  local closest_delta = math.abs(width - closest)

  for index = 2, #width_options do
    local option = width_options[index]
    local delta = math.abs(width - option)
    if delta < closest_delta then
      closest = option
      closest_delta = delta
    end
  end

  return closest
end

function M.undo_stack_cap()
  return settings.global["doodle-undo-stack-cap"].value
end

function M.color_options()
  return ColorPresets.ids()
end

function M.color_option_label(option)
  return { ColorPresets.locale_key(option) }
end

function M.color_option_index(value)
  for index, option in ipairs(ColorPresets.ids()) do
    if option == value then
      return index
    end
  end

  return 1
end

function M.line_color_setting(player)
  if not (player and player.valid) then
    return "player"
  end

  return settings.get_player_settings(player.index)["doodle-line-color"].value
end

function M.set_line_color_setting(player, value)
  if not (player and player.valid) then
    return
  end

  settings.get_player_settings(player.index)["doodle-line-color"] = { value = value }
end

function M.color_for_setting(player, setting_value)
  if not (player and player.valid) then
    return { r = 1, g = 1, b = 1, a = 1 }
  end

  if setting_value == "player" then
    return Util.copy_color(player.color)
  end

  return Util.copy_color(ColorPresets.preset_color(setting_value) or ColorPresets.preset_color("white"))
end

function M.sync_style_color(player, state)
  if not state or not state.style then
    return
  end

  state.style.color = M.color_for_setting(player, M.line_color_setting(player))
end

function M.default_color(player)
  return M.color_for_setting(player, M.line_color_setting(player))
end

function M.default_style(player)
  return {
    color = M.default_color(player),
    width = M.default_line_width()
  }
end

M.refresh()

return M
