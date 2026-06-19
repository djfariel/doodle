local Constants = require("scripts.constants")
local RenderService = require("scripts.render_service")
local PlayerState = require("scripts.player_state")
local Util = require("scripts.util")

local M = {}

function M.index(doodle)
  PlayerState.ensure()

  local owner_index = doodle.owner_player_index
  storage.doodle.by_owner[owner_index] = storage.doodle.by_owner[owner_index] or {}
  storage.doodle.by_owner[owner_index][doodle.id] = true

  local surface_index = doodle.surface_index
  storage.doodle.by_surface[surface_index] = storage.doodle.by_surface[surface_index] or {}
  storage.doodle.by_surface[surface_index][doodle.id] = true
end

function M.unindex(doodle)
  PlayerState.ensure()

  local owner_map = storage.doodle.by_owner[doodle.owner_player_index]
  if owner_map then
    owner_map[doodle.id] = nil
    if not next(owner_map) then
      storage.doodle.by_owner[doodle.owner_player_index] = nil
    end
  end

  local surface_map = storage.doodle.by_surface[doodle.surface_index]
  if surface_map then
    surface_map[doodle.id] = nil
    if not next(surface_map) then
      storage.doodle.by_surface[doodle.surface_index] = nil
    end
  end
end

function M.purge_doodle(doodle)
  if not doodle then
    return
  end

  PlayerState.ensure()
  RenderService.destroy_doodle_render_objects(doodle)
  M.unindex(doodle)
  storage.doodle.doodles[doodle.id] = nil
end

function M.purge_surface(surface_index)
  PlayerState.ensure()

  local surface_map = storage.doodle.by_surface[surface_index]
  if not surface_map then
    return 0
  end

  local count = 0
  for doodle_id in pairs(surface_map) do
    local doodle = storage.doodle.doodles[doodle_id]
    if doodle then
      M.purge_doodle(doodle)
      count = count + 1
    end
  end

  storage.doodle.by_surface[surface_index] = nil
  return count
end

local function owned_doodle_ids(player)
  PlayerState.ensure()

  local owner_map = storage.doodle.by_owner[player.index]
  if not owner_map then
    return nil
  end

  local ids = {}
  for doodle_id in pairs(owner_map) do
    ids[#ids + 1] = doodle_id
  end

  return ids
end

local function for_each_owned_doodle(player, surface_index, fn)
  local ids = owned_doodle_ids(player)
  if not ids then
    return
  end

  for _, doodle_id in ipairs(ids) do
    local doodle = storage.doodle.doodles[doodle_id]
    if doodle and (not surface_index or doodle.surface_index == surface_index) then
      fn(doodle)
    end
  end
end

function M.purge_all_owned_for_player(player)
  if not (player and player.valid) then
    return 0
  end

  local count = 0
  for_each_owned_doodle(player, nil, function(doodle)
    M.purge_doodle(doodle)
    count = count + 1
  end)

  return count
end

local function allocate_id()
  PlayerState.ensure()
  local id = storage.doodle.next_doodle_id
  storage.doodle.next_doodle_id = id + 1
  return id
end

local function create_doodle(player, surface, doodle_type, geometry)
  if not player or not surface or not surface.valid then
    return nil
  end

  PlayerState.ensure()

  local state = PlayerState.get_player(player.index)
  local doodle = {
    id = allocate_id(),
    type = doodle_type,
    owner_player_index = player.index,
    owner_force_name = player.force.name,
    surface_index = surface.index,
    created_tick = game.tick,
    geometry = geometry,
    style = Util.copy_style(state.style),
    render_ids = {}
  }

  doodle.render_ids = RenderService.render_doodle(doodle)
  storage.doodle.doodles[doodle.id] = doodle
  M.index(doodle)

  return doodle
end

function M.create_polyline(player, points, surface)
  if not points or #points < 2 then
    return nil
  end

  return create_doodle(player, surface, Constants.DOODLE_TYPE_POLYLINE, {
    points = Util.copy_points(points)
  })
end

function M.create_arrow(player, from_point, to_point, surface)
  if not from_point or not to_point then
    return nil
  end

  return create_doodle(player, surface, Constants.DOODLE_TYPE_ARROW, {
    from = Util.copy_position(from_point),
    to = Util.copy_position(to_point)
  })
end

function M.create_rectangle(player, left_top, right_bottom, surface)
  if not left_top or not right_bottom then
    return nil
  end

  return create_doodle(player, surface, Constants.DOODLE_TYPE_RECTANGLE, {
    left_top = Util.copy_position(left_top),
    right_bottom = Util.copy_position(right_bottom)
  })
end

function M.create_circle(player, center, radius, surface)
  if not center or not radius or radius < Constants.MIN_CIRCLE_RADIUS then
    return nil
  end

  return create_doodle(player, surface, Constants.DOODLE_TYPE_CIRCLE, {
    center = Util.copy_position(center),
    radius = radius
  })
end

function M.delete_owned(player, doodle_id)
  if not player or not player.valid then
    return nil
  end

  PlayerState.ensure()

  local doodle = storage.doodle.doodles[doodle_id]
  if not doodle or doodle.owner_player_index ~= player.index then
    return nil
  end

  local snapshot = Util.copy_doodle(doodle)
  M.purge_doodle(doodle)
  return snapshot
end

function M.restore_doodle(snapshot)
  if not snapshot then
    return nil
  end

  PlayerState.ensure()

  local doodle = Util.copy_doodle(snapshot)
  doodle.render_ids = RenderService.render_doodle(doodle)
  storage.doodle.doodles[doodle.id] = doodle
  M.index(doodle)

  if doodle.id >= storage.doodle.next_doodle_id then
    storage.doodle.next_doodle_id = doodle.id + 1
  end

  return doodle
end

function M.clear_owned_for_player(player, surface_index)
  if not player or not player.valid then
    return {}
  end

  local deleted_snapshots = {}
  for_each_owned_doodle(player, surface_index, function(doodle)
    deleted_snapshots[#deleted_snapshots + 1] = Util.copy_doodle(doodle)
    M.purge_doodle(doodle)
  end)

  return deleted_snapshots
end

return M
