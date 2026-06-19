-- Per-player runtime state and storage.doodle bootstrap. Uses Factorio global
-- `storage` (lowercase); this module is PlayerState, not the global table.

local SettingValues = require("scripts.setting_values")
local Preview = require("scripts.preview")

local M = {}

local function default_style(player)
  return SettingValues.default_style(player)
end

function M.ensure()
  storage.doodle = storage.doodle or {}
  storage.doodle.next_doodle_id = storage.doodle.next_doodle_id or 1
  storage.doodle.doodles = storage.doodle.doodles or {}
  storage.doodle.by_owner = storage.doodle.by_owner or {}
  storage.doodle.by_surface = storage.doodle.by_surface or {}
  storage.doodle.players = storage.doodle.players or {}
  storage.doodle.leaving_players = storage.doodle.leaving_players or {}
end

function M.mark_player_leaving(player_index)
  M.ensure()
  storage.doodle.leaving_players[player_index] = true
end

function M.clear_player_leaving(player_index)
  M.ensure()
  storage.doodle.leaving_players[player_index] = nil
end

function M.is_player_leaving(player_index)
  M.ensure()
  return storage.doodle.leaving_players[player_index] == true
end

function M.get_player(player_index)
  M.ensure()

  local state = storage.doodle.players[player_index]
  if state then
    if not state.preview then
      state.preview = Preview.create()
    end
    return state
  end

  if M.is_player_leaving(player_index) then
    return nil
  end

  local player = game.get_player(player_index)
  state = {
    active_tool_id = nil,
    in_progress = nil,
    preview = Preview.create(),
    clear_confirm_open = false,
    clear_surface_index = nil,
    undo_stack = {},
    redo_stack = {},
    style = default_style(player)
  }

  storage.doodle.players[player_index] = state
  return state
end

function M.remove_player(player_index)
  M.ensure()

  local state = storage.doodle.players[player_index]
  if state then
    Preview.destroy(state.preview)
  end

  storage.doodle.players[player_index] = nil
end

function M.each_player_state(fn)
  M.ensure()

  for player_index, state in pairs(storage.doodle.players or {}) do
    fn(player_index, state)
  end
end

return M
