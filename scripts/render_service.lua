local Constants = require("scripts.constants")
local DoodleStore = require("scripts.doodle_store")
local RenderAudience = require("scripts.render_audience")
local RenderDraw = require("scripts.render_draw")

local M = {}

function M.destroy_doodle_render_objects(doodle)
  RenderDraw.destroy_render_ids(doodle.render_ids)
  doodle.render_ids = {}
end

function M.render_doodle(doodle)
  local surface = game.surfaces[doodle.surface_index]
  if not surface or not surface.valid then
    return {}
  end

  local audience = RenderAudience.for_doodle(doodle)
  local geometry = doodle.geometry
  local style = doodle.style

  if doodle.type == Constants.DOODLE_TYPE_POLYLINE then
    return RenderDraw.draw_polyline(surface, geometry.points, style, audience)
  end

  if doodle.type == Constants.DOODLE_TYPE_ARROW then
    return RenderDraw.draw_arrow(surface, geometry.from, geometry.to, style, audience)
  end

  if doodle.type == Constants.DOODLE_TYPE_RECTANGLE then
    return RenderDraw.draw_rectangle(surface, geometry.left_top, geometry.right_bottom, style, audience)
  end

  if doodle.type == Constants.DOODLE_TYPE_CIRCLE then
    return RenderDraw.draw_circle_shape(surface, geometry.center, geometry.radius, style, audience)
  end

  return {}
end

function M.rerender_doodle(doodle)
  M.destroy_doodle_render_objects(doodle)
  doodle.render_ids = M.render_doodle(doodle)
end

function M.render_ids_valid(doodle)
  if not doodle.render_ids or #doodle.render_ids == 0 then
    return false
  end

  for _, render_id in pairs(doodle.render_ids) do
    local object = rendering.get_object_by_id(render_id)
    if not object or not object.valid then
      return false
    end
  end

  return true
end

function M.repair_all()
  DoodleStore.each_doodle(function(doodle)
    if not M.render_ids_valid(doodle) then
      M.rerender_doodle(doodle)
    end
  end)
end

function M.repair_for_player(player)
  if not player or not player.valid then
    return
  end

  DoodleStore.each_doodle_for_force(player.force.name, function(doodle)
    if not M.render_ids_valid(doodle) then
      M.rerender_doodle(doodle)
    end
  end)
end

return M
