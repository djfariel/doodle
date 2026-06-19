local SettingValues = require("scripts.setting_values")
local EmofRefresh = require("scripts.emof_refresh")
local DoodleStore = require("scripts.doodle_store")
local Repository = require("scripts.repository")
local PlayerState = require("scripts.player_state")
local Util = require("scripts.util")

local M = {}

local function trim_stack(stack, cap)
  while #stack > cap do
    table.remove(stack, 1)
  end
end

local function trim_player_history(state, cap, player)
  state.undo_stack = state.undo_stack or {}
  state.redo_stack = state.redo_stack or {}
  trim_stack(state.undo_stack, cap)
  trim_stack(state.redo_stack, cap)

  if player and player.valid then
    EmofRefresh.refresh_chart_controls(player)
  end
end

function M.apply_stack_cap_all()
  PlayerState.ensure()
  local cap = SettingValues.undo_stack_cap()

  PlayerState.each_player_state(function(player_index, state)
    trim_player_history(state, cap, game.get_player(player_index))
  end)
end

function M.can_undo(player)
  local state = PlayerState.get_player(player.index)
  return state ~= nil and #(state.undo_stack or {}) > 0
end

function M.can_redo(player)
  local state = PlayerState.get_player(player.index)
  return state ~= nil and #(state.redo_stack or {}) > 0
end

local function push_command(player, command)
  local state = PlayerState.get_player(player.index)
  state.undo_stack = state.undo_stack or {}
  state.redo_stack = state.redo_stack or {}

  command.actor_player_index = player.index
  command.tick = game.tick

  state.undo_stack[#state.undo_stack + 1] = command
  trim_stack(state.undo_stack, SettingValues.undo_stack_cap())
  state.redo_stack = {}
  EmofRefresh.refresh_chart_controls(player)
end

local function apply_create(snapshot)
  return Repository.restore_doodle(snapshot)
end

local function apply_delete(snapshot)
  local doodle = DoodleStore.get_owned_doodle(snapshot.owner_player_index, snapshot.id)
  if not doodle then
    return false
  end

  Repository.purge_doodle(doodle)
  return true
end

function M.undo(player)
  local state = PlayerState.get_player(player.index)
  state.undo_stack = state.undo_stack or {}
  state.redo_stack = state.redo_stack or {}

  if #state.undo_stack == 0 then
    return false
  end

  local command = state.undo_stack[#state.undo_stack]
  table.remove(state.undo_stack)

  local ok = false
  if command.type == "create" then
    ok = apply_delete(command.after)
  elseif command.type == "delete" then
    ok = apply_create(command.before) ~= nil
  elseif command.type == "clear_owned" then
    for _, snapshot in ipairs(command.before or {}) do
      apply_create(snapshot)
    end
    ok = true
  end

  if ok then
    state.redo_stack[#state.redo_stack + 1] = command
    trim_stack(state.redo_stack, SettingValues.undo_stack_cap())
  else
    state.undo_stack[#state.undo_stack + 1] = command
  end

  EmofRefresh.refresh_chart_controls(player)
  return ok
end

function M.redo(player)
  local state = PlayerState.get_player(player.index)
  state.undo_stack = state.undo_stack or {}
  state.redo_stack = state.redo_stack or {}

  if #state.redo_stack == 0 then
    return false
  end

  local command = state.redo_stack[#state.redo_stack]
  table.remove(state.redo_stack)

  local ok = false
  if command.type == "create" then
    ok = apply_create(command.after) ~= nil
  elseif command.type == "delete" then
    ok = apply_delete(command.before)
  elseif command.type == "clear_owned" then
    for _, snapshot in ipairs(command.before or {}) do
      apply_delete(snapshot)
    end
    ok = true
  end

  if ok then
    state.undo_stack[#state.undo_stack + 1] = command
    trim_stack(state.undo_stack, SettingValues.undo_stack_cap())
  else
    state.redo_stack[#state.redo_stack + 1] = command
  end

  EmofRefresh.refresh_chart_controls(player)
  return ok
end

function M.clear_history(player)
  local state = PlayerState.get_player(player.index)
  if not state then
    return
  end

  state.undo_stack = {}
  state.redo_stack = {}
  EmofRefresh.refresh_chart_controls(player)
end

function M.record_create(player, doodle)
  push_command(player, {
    type = "create",
    after = Util.copy_doodle(doodle)
  })
end

function M.record_delete(player, doodle_snapshot)
  push_command(player, {
    type = "delete",
    before = Util.copy_doodle(doodle_snapshot)
  })
end

function M.record_clear_owned(player, snapshots)
  push_command(player, {
    type = "clear_owned",
    before = snapshots
  })
end

return M
