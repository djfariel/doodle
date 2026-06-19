local Constants = require("scripts.constants")
local UndoService = require("scripts.undo_service")

local M = {}

function M.is_undo_enabled(payload)
  local player = game.get_player(payload.player_index)
  if not (player and player.valid) then
    return false
  end

  return UndoService.can_undo(player)
end

function M.is_redo_enabled(payload)
  local player = game.get_player(payload.player_index)
  if not (player and player.valid) then
    return false
  end

  return UndoService.can_redo(player)
end

function M.register_remote_interface()
  remote.add_interface(Constants.MAP_ACTIONS_INTERFACE, {
    is_undo_enabled = M.is_undo_enabled,
    is_redo_enabled = M.is_redo_enabled
  })
end

return M
