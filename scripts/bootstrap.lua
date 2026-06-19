local EmofApi = require("scripts.emof_api")
local PlayerState = require("scripts.player_state")
local RenderService = require("scripts.render_service")
local SettingValues = require("scripts.setting_values")

local M = {}

local render_repair_pending = false

local function bootstrap_reload()
  SettingValues.refresh()
  PlayerState.ensure()
  EmofApi.register_map_tools()
  EmofApi.notify_all_players()
  RenderService.repair_all()
end

local function schedule_render_repair()
  render_repair_pending = true
end

function M.on_init()
  bootstrap_reload()
end

function M.on_configuration_changed()
  bootstrap_reload()
  schedule_render_repair()
end

function M.on_load()
  -- Save load re-executes Lua modules; defer render repair until nth_tick.
  -- Must not read or write storage here (Factorio save/load stability).
  schedule_render_repair()
end

function M.maybe_repair_renders_after_load()
  if not render_repair_pending then
    return
  end

  render_repair_pending = false
  RenderService.repair_all()
end

return M
