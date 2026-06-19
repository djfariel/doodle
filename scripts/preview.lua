local Constants = require("scripts.constants")
local Geometry = require("scripts.geometry")
local RenderDraw = require("scripts.render_draw")

local M = {}

function M.create()
  return {
    segments = {},
    controls = {}
  }
end

function M.destroy(preview)
  if not preview then
    return
  end

  RenderDraw.destroy_render_ids(preview.segments)
  RenderDraw.destroy_render_ids(preview.controls)
  preview.segments = {}
  preview.controls = {}
end

function M.redraw(preview, surface, points, style, audience)
  M.destroy(preview)

  if not (surface and surface.valid) then
    return
  end

  if #points >= 2 then
    preview.segments = RenderDraw.draw_polyline(surface, points, style, audience)
  end

  if #points >= 1 then
    preview.controls = RenderDraw.draw_control_points(surface, points, style, audience)
  end
end

function M.redraw_segment(preview, surface, from, to, style, audience)
  M.destroy(preview)

  if not (surface and surface.valid) then
    return
  end

  if from and to then
    preview.segments = RenderDraw.draw_arrow(surface, from, to, style, audience)
    preview.controls = RenderDraw.draw_control_points(surface, { from }, style, audience)
  elseif from then
    preview.controls = RenderDraw.draw_control_points(surface, { from }, style, audience)
  end
end

function M.redraw_rect(preview, surface, corner_a, corner_b, style, audience)
  M.destroy(preview)

  if not (surface and surface.valid) then
    return
  end

  if corner_a and corner_b then
    local corners = Geometry.normalize_rect_corners(corner_a, corner_b)
    preview.segments = RenderDraw.draw_rectangle(surface, corners.left_top, corners.right_bottom, style, audience)
    preview.controls = RenderDraw.draw_control_points(surface, { corner_a }, style, audience)
  elseif corner_a then
    preview.controls = RenderDraw.draw_control_points(surface, { corner_a }, style, audience)
  end
end

function M.redraw_circle(preview, surface, center, edge, style, audience)
  M.destroy(preview)

  if not (surface and surface.valid) then
    return
  end

  if center and edge then
    local radius = Geometry.distance(center, edge)
    if radius >= Constants.MIN_CIRCLE_RADIUS then
      preview.segments = RenderDraw.draw_circle_shape(surface, center, radius, style, audience)
    end
    preview.controls = RenderDraw.draw_control_points(surface, { center }, style, audience)
  elseif center then
    preview.controls = RenderDraw.draw_control_points(surface, { center }, style, audience)
  end
end

return M
