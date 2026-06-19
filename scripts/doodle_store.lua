-- Read-only access and iteration over persisted doodles. No render or mutation
-- dependencies so render_service and repository can both use this module.

local PlayerState = require("scripts.player_state")

local M = {}

function M.get_doodle(doodle_id)
  PlayerState.ensure()
  return storage.doodle.doodles[doodle_id]
end

function M.get_owned_doodle(owner_player_index, doodle_id)
  local doodle = M.get_doodle(doodle_id)
  if doodle and doodle.owner_player_index == owner_player_index then
    return doodle
  end

  return nil
end

function M.each_doodle(fn)
  PlayerState.ensure()

  for _, doodle in pairs(storage.doodle.doodles or {}) do
    if doodle then
      fn(doodle)
    end
  end
end

function M.each_doodle_for_force(force_name, fn)
  M.each_doodle(function(doodle)
    if doodle.owner_force_name == force_name then
      fn(doodle)
    end
  end)
end

function M.each_on_surface_owned(surface_index, owner_player_index, fn)
  PlayerState.ensure()

  local surface_map = storage.doodle.by_surface[surface_index]
  if not surface_map then
    return
  end

  for doodle_id in pairs(surface_map) do
    local doodle = storage.doodle.doodles[doodle_id]
    if doodle and doodle.owner_player_index == owner_player_index then
      fn(doodle)
    end
  end
end

return M
