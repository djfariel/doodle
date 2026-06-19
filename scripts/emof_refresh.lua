local Constants = require("scripts.constants")

local M = {}

local function log_emof_failure(function_name, err)
  if log then
    log(
      "[doodle] "
        .. Constants.EMOF_INTERFACE_NAME
        .. "."
        .. function_name
        .. " failed: "
        .. tostring(err)
    )
  end
end

function M.call(function_name, ...)
  local ok, result = pcall(remote.call, Constants.EMOF_INTERFACE_NAME, function_name, ...)
  if not ok then
    log_emof_failure(function_name, result)
    return nil
  end

  return result
end

function M.refresh_chart_controls(player)
  if not (player and player.valid) then
    return
  end

  M.call("sync_chart_controls", player.index)
end

return M
