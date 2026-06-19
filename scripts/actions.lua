local Repository = require("scripts.repository")
local UndoService = require("scripts.undo_service")

local M = {}

local function record_create(player, doodle)
  if doodle then
    UndoService.record_create(player, doodle)
  end
  return doodle
end

function M.create_polyline(player, points, surface)
  return record_create(player, Repository.create_polyline(player, points, surface))
end

function M.create_arrow(player, from_point, to_point, surface)
  return record_create(player, Repository.create_arrow(player, from_point, to_point, surface))
end

function M.create_rectangle(player, left_top, right_bottom, surface)
  return record_create(player, Repository.create_rectangle(player, left_top, right_bottom, surface))
end

function M.create_circle(player, center, radius, surface)
  return record_create(player, Repository.create_circle(player, center, radius, surface))
end

function M.delete_owned(player, doodle_id)
  local snapshot = Repository.delete_owned(player, doodle_id)
  if snapshot then
    UndoService.record_delete(player, snapshot)
  end
  return snapshot
end

function M.clear_owned_for_player(player, surface_index)
  local snapshots = Repository.clear_owned_for_player(player, surface_index)
  if #snapshots > 0 then
    UndoService.record_clear_owned(player, snapshots)
  end
  return snapshots
end

return M
