local Constants = require("scripts.constants")
local Geometry = require("scripts.geometry")
local PlayerState = require("scripts.player_state")
local DoodleStore = require("scripts.doodle_store")

local M = {}

local function hit_tolerance_for_style(style, override_tolerance)
  if override_tolerance then
    return override_tolerance
  end

  local width = (style and style.width) or 1
  return width / 2 + Constants.ERASER_TOLERANCE_BASE
end

local function hit_distance_for_doodle(doodle, position)
  local geometry = doodle.geometry
  local style = doodle.style or {}

  if doodle.type == Constants.DOODLE_TYPE_POLYLINE then
    return Geometry.min_distance_to_polyline(position, geometry.points)
  end

  if doodle.type == Constants.DOODLE_TYPE_ARROW then
    return Geometry.distance_to_segment(position, geometry.from, geometry.to)
  end

  if doodle.type == Constants.DOODLE_TYPE_RECTANGLE then
    return Geometry.distance_to_rect_edges(position, geometry.left_top, geometry.right_bottom)
  end

  if doodle.type == Constants.DOODLE_TYPE_CIRCLE then
    return Geometry.distance_to_circle(position, geometry.center, geometry.radius)
  end

  return math.huge
end

function M.find_nearest_owned(player, surface_index, position, tolerance)
  if not (player and player.valid and position and surface_index) then
    return nil
  end

  PlayerState.ensure()

  local nearest_doodle = nil
  local nearest_distance = math.huge

  DoodleStore.each_on_surface_owned(surface_index, player.index, function(doodle)
    local distance = hit_distance_for_doodle(doodle, position)
    local hit_tolerance = hit_tolerance_for_style(doodle.style, tolerance)
    if distance <= hit_tolerance then
      if not nearest_doodle
        or distance < nearest_distance
        or (distance == nearest_distance and doodle.id > nearest_doodle.id) then
        nearest_distance = distance
        nearest_doodle = doodle
      end
    end
  end)

  return nearest_doodle
end

return M
