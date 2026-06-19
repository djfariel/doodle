local Constants = require("scripts.constants")

local M = {}

function M.fallback_surface_index(player)
  if not (player and player.valid) then
    return nil
  end

  local surface = player.surface or player.physical_surface
  return surface and surface.valid and surface.index or nil
end

function M.copy_position(position)
  if not position then
    return nil
  end

  return { x = position.x, y = position.y }
end

function M.copy_color(color)
  if not color then
    return { r = 1, g = 1, b = 1, a = 1 }
  end

  return {
    r = color.r,
    g = color.g,
    b = color.b,
    a = color.a or 1
  }
end

function M.copy_style(style)
  return {
    color = M.copy_color(style.color),
    width = style.width
  }
end

function M.copy_points(points)
  local result = {}

  for index, point in ipairs(points or {}) do
    result[index] = M.copy_position(point)
  end

  return result
end

function M.copy_geometry(geometry, doodle_type)
  if not geometry then
    return {}
  end

  if doodle_type == Constants.DOODLE_TYPE_POLYLINE then
    return {
      points = M.copy_points(geometry.points)
    }
  end

  if doodle_type == Constants.DOODLE_TYPE_ARROW then
    return {
      from = M.copy_position(geometry.from),
      to = M.copy_position(geometry.to)
    }
  end

  if doodle_type == Constants.DOODLE_TYPE_RECTANGLE then
    return {
      left_top = M.copy_position(geometry.left_top),
      right_bottom = M.copy_position(geometry.right_bottom)
    }
  end

  if doodle_type == Constants.DOODLE_TYPE_CIRCLE then
    return {
      center = M.copy_position(geometry.center),
      radius = geometry.radius
    }
  end

  return {}
end

function M.copy_doodle(doodle)
  if not doodle then
    return nil
  end

  return {
    id = doodle.id,
    type = doodle.type,
    owner_player_index = doodle.owner_player_index,
    owner_force_name = doodle.owner_force_name,
    surface_index = doodle.surface_index,
    created_tick = doodle.created_tick,
    geometry = M.copy_geometry(doodle.geometry, doodle.type),
    style = M.copy_style(doodle.style),
    render_ids = {}
  }
end

return M
