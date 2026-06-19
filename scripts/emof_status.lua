-- EMOF availability state and player notification. Kept separate from emof_api
-- so input can require this without the action_dispatch -> input cycle.

local M = {}

local available = true
local failure_reason = nil

local function log_message(message)
  if log then
    log("[doodle] " .. message)
  end
end

function M.available()
  return available
end

function M.failure_reason()
  return failure_reason
end

function M.reset()
  available = true
  failure_reason = nil
end

function M.fail(user_message, log_detail)
  available = false
  failure_reason = user_message
  log_message(log_detail or user_message)
end

function M.notify_player(player)
  if available or not failure_reason or not (player and player.valid) then
    return
  end

  player.print({ "doodle-message.emof-unavailable", failure_reason })
end

function M.notify_all_players()
  if available then
    return
  end

  for _, player in pairs(game.connected_players) do
    M.notify_player(player)
  end
end

return M
