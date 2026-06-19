local Constants = require("scripts.constants")
local Bootstrap = require("scripts.bootstrap")
local EmofApi = require("scripts.emof_api")
local Gui = require("scripts.gui")
local Input = require("scripts.input")
local MapActions = require("scripts.map_actions")
local PlayerState = require("scripts.player_state")
local Repository = require("scripts.repository")

EmofApi.register_map_tool_interface()
MapActions.register_remote_interface()

if not EmofApi.register_events() then
  log("[doodle] Extensible Map Overlay Framework integration disabled: " .. tostring(EmofApi.failure_reason()))
end

script.on_init(Bootstrap.on_init)

script.on_configuration_changed(Bootstrap.on_configuration_changed)

script.on_load(Bootstrap.on_load)

script.on_nth_tick(Constants.RENDER_REPAIR_INTERVAL, Bootstrap.maybe_repair_renders_after_load)

script.on_event(Constants.INPUT_UNDO, function(event)
  local player = game.get_player(event.player_index)
  if player then
    Input.on_undo(player)
  end
end)

script.on_event(Constants.INPUT_REDO, function(event)
  local player = game.get_player(event.player_index)
  if player then
    Input.on_redo(player)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local button_name = Gui.handle_click(event)
  if button_name then
    Input.on_toolbar_control(event, button_name)
  end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
  local control_name = Gui.handle_value_changed(event)
  if control_name then
    Input.on_toolbar_control(event, control_name)
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local control_name = Gui.handle_selection_state_changed(event)
  if control_name then
    Input.on_gui_selection_state_changed(event, control_name)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  Input.on_runtime_mod_setting_changed(event)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if not event.element or not event.element.valid then
    return
  end

  if event.element.name == Constants.EMOF_PANEL_NAME then
    local player = game.get_player(event.player_index)
    if player then
      Input.on_chart_controls_closed(player)
    end
  end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  PlayerState.clear_player_leaving(player.index)
  Input.on_player_joined_game(player)
end)

script.on_event(defines.events.on_player_left_game, function(event)
  Input.on_player_left_game(event)
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  Input.on_player_changed_force(event)
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  Repository.purge_surface(event.surface_index)
end)
