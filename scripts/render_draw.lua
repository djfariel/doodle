-- Low-level chart rendering. Callers pass an audience table from render_audience.lua
-- (force for committed doodles, player for in-progress previews).

local Constants = require("scripts.constants")
local Util = require("scripts.util")

local M = {}

local function audience_configured(audience)
  if not audience then
    return false
  end

  if audience.forces and #audience.forces > 0 then
    return true
  end

  if audience.players and #audience.players > 0 then
    return true
  end

  return false
end

local function with_audience(params, audience)
  if audience.forces then
    params.forces = audience.forces
  end

  if audience.players then
    params.players = audience.players
  end

  return params
end

function M.destroy_render_ids(render_ids)
  for _, render_id in pairs(render_ids or {}) do
    local object = rendering.get_object_by_id(render_id)
    if object and object.valid then
      object.destroy()
    end
  end
end

function M.style_color(style)
  return Util.copy_color(style.color)
end

function M.draw_polyline(surface, points, style, audience)
  if not surface or not surface.valid or #points < 2 or not audience_configured(audience) then
    return {}
  end

  local render_ids = {}
  local color = M.style_color(style)

  for index = 2, #points do
    local object = rendering.draw_line(with_audience({
      surface = surface,
      from = points[index - 1],
      to = points[index],
      color = color,
      width = style.width,
      render_mode = "chart"
    }, audience))

    if object then
      render_ids[#render_ids + 1] = object.id
    end
  end

  return render_ids
end

function M.draw_segment(surface, from, to, style, audience)
  if not surface or not surface.valid or not from or not to or not audience_configured(audience) then
    return {}
  end

  local object = rendering.draw_line(with_audience({
    surface = surface,
    from = from,
    to = to,
    color = M.style_color(style),
    width = style.width,
    render_mode = "chart"
  }, audience))

  if object then
    return { object.id }
  end

  return {}
end

local function append_render_ids(target, source)
  for _, render_id in ipairs(source or {}) do
    target[#target + 1] = render_id
  end
end

function M.draw_arrow(surface, from, to, style, audience)
  if not surface or not surface.valid or not from or not to or not audience_configured(audience) then
    return {}
  end

  local render_ids = {}
  append_render_ids(render_ids, M.draw_segment(surface, from, to, style, audience))

  local dx = to.x - from.x
  local dy = to.y - from.y
  local length = math.sqrt(dx * dx + dy * dy)
  if length < 0.01 then
    return render_ids
  end

  local head_length = math.max(style.width * 0.15, 0.4)
  local head_angle = math.rad(25)
  local ux = dx / length
  local uy = dy / length
  local bx = -ux
  local by = -uy
  local color = M.style_color(style)
  local width = style.width

  for _, theta in ipairs({ head_angle, -head_angle }) do
    local cos_t = math.cos(theta)
    local sin_t = math.sin(theta)
    local wing_to = {
      x = to.x + (bx * cos_t - by * sin_t) * head_length,
      y = to.y + (bx * sin_t + by * cos_t) * head_length
    }
    local object = rendering.draw_line(with_audience({
      surface = surface,
      from = to,
      to = wing_to,
      color = color,
      width = width,
      render_mode = "chart"
    }, audience))
    if object then
      render_ids[#render_ids + 1] = object.id
    end
  end

  return render_ids
end

function M.draw_rectangle(surface, left_top, right_bottom, style, audience)
  if not surface or not surface.valid or not left_top or not right_bottom or not audience_configured(audience) then
    return {}
  end

  local object = rendering.draw_rectangle(with_audience({
    surface = surface,
    left_top = left_top,
    right_bottom = right_bottom,
    color = M.style_color(style),
    width = style.width,
    filled = false,
    render_mode = "chart"
  }, audience))

  if object then
    return { object.id }
  end

  return {}
end

function M.draw_circle_shape(surface, center, radius, style, audience)
  if not surface or not surface.valid or not center or not radius or radius <= 0 or not audience_configured(audience) then
    return {}
  end

  local object = rendering.draw_circle(with_audience({
    surface = surface,
    target = center,
    radius = radius,
    color = M.style_color(style),
    width = style.width,
    filled = false,
    render_mode = "chart"
  }, audience))

  if object then
    return { object.id }
  end

  return {}
end

function M.draw_control_points(surface, points, style, audience, options)
  options = options or {}

  if not surface or not surface.valid or #points == 0 or not audience_configured(audience) then
    return {}
  end

  local render_ids = {}
  local color = M.style_color(style)
  local radius = options.radius or Constants.CONTROL_POINT_RADIUS

  for _, point in ipairs(points) do
    local object = rendering.draw_circle(with_audience({
      surface = surface,
      target = point,
      color = color,
      radius = radius,
      filled = true,
      scale_with_zoom = true,
      render_mode = "chart"
    }, audience))

    if object then
      render_ids[#render_ids + 1] = object.id
    end
  end

  return render_ids
end

return M
