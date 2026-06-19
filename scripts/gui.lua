local Constants = require("scripts.constants")
local SettingValues = require("scripts.setting_values")
local PlayerState = require("scripts.player_state")

local M = {}

local GUI = Constants.GUI

local WIDTH_TOOLBAR_TOOLS = {
  [Constants.TOOL_LINE] = true,
  [Constants.TOOL_ARROW] = true,
  [Constants.TOOL_SQUARE] = true,
  [Constants.TOOL_CIRCLE] = true
}

local function uses_width_toolbar(active_tool_id)
  return WIDTH_TOOLBAR_TOOLS[active_tool_id] == true
end

local function point_count(state)
  if not state.in_progress or not state.in_progress.points then
    return 0
  end

  return #state.in_progress.points
end

local function width_slider_index(width)
  for index, option in ipairs(SettingValues.width_options()) do
    if option == width then
      return index
    end
  end

  return 1
end

local function get_extension_slot(player)
  local panel = player.gui.screen[Constants.EMOF_PANEL_NAME]
  if not (panel and panel.valid) then
    return nil
  end

  local slot = panel[Constants.EMOF_EXTENSION_SLOT]
  if slot and slot.valid then
    return slot
  end

  return nil
end

local function set_slot_visible(slot, visible)
  if slot and slot.valid then
    slot.visible = visible
  end
end

local function slot_has_content(slot)
  return slot and slot.valid and #slot.children > 0
end

local function sync_slot_visibility(slot)
  set_slot_visible(slot, slot_has_content(slot))
end

local function destroy_if_valid(element)
  if element and element.valid then
    element.destroy()
  end
end

local function ensure_toolbar(toolbar, state)
  if toolbar[GUI.style_row] and toolbar[GUI.color_row] and toolbar[GUI.buttons] then
    return
  end

  destroy_if_valid(toolbar[GUI.style_row])
  destroy_if_valid(toolbar[GUI.color_row])
  destroy_if_valid(toolbar[GUI.buttons])

  local style_row = toolbar.add {
    type = "flow",
    name = GUI.style_row,
    direction = "horizontal"
  }

  style_row.add {
    type = "label",
    name = GUI.width_label,
    caption = { "doodle-gui.width-label" }
  }

  style_row.add {
    type = "slider",
    name = GUI.width_slider,
    minimum_value = 1,
    maximum_value = #SettingValues.width_options(),
    value = width_slider_index(state.style.width)
  }

  style_row.add {
    type = "label",
    name = GUI.width_value,
    caption = tostring(state.style.width)
  }

  local color_row = toolbar.add {
    type = "flow",
    name = GUI.color_row,
    direction = "horizontal"
  }

  color_row.add {
    type = "label",
    name = GUI.color_label,
    caption = { "doodle-gui.color-label" }
  }

  local color_dropdown = color_row.add {
    type = "drop-down",
    name = GUI.color_dropdown
  }

  for _, option in ipairs(SettingValues.color_options()) do
    color_dropdown.add_item(SettingValues.color_option_label(option))
  end

  local buttons = toolbar.add {
    type = "flow",
    name = GUI.buttons,
    direction = "horizontal"
  }

  buttons.add {
    type = "button",
    name = GUI.finish_button,
    caption = { "doodle-gui.finish-line" }
  }

  buttons.add {
    type = "button",
    name = GUI.cancel_button,
    caption = { "doodle-gui.cancel-line" }
  }
end

local function ensure_clear_confirm(confirm)
  if confirm[GUI.confirm_buttons] then
    return
  end

  confirm.add {
    type = "label",
    name = GUI.clear_confirm_label,
    caption = { "doodle-gui.clear-confirm" }
  }

  local confirm_buttons = confirm.add {
    type = "flow",
    name = GUI.confirm_buttons,
    direction = "horizontal"
  }

  confirm_buttons.add {
    type = "button",
    name = GUI.clear_confirm_button,
    caption = { "doodle-gui.clear-confirm-yes" },
    style = "red_button"
  }

  confirm_buttons.add {
    type = "button",
    name = GUI.clear_cancel_button,
    caption = { "doodle-gui.clear-confirm-no" }
  }
end

local function update_toolbar(player, slot, state)
  local toolbar = slot[GUI.toolbar]

  if not uses_width_toolbar(state.active_tool_id) then
    destroy_if_valid(toolbar)
    return
  end

  if not (toolbar and toolbar.valid) then
    toolbar = slot.add {
      type = "flow",
      name = GUI.toolbar,
      direction = "vertical"
    }
  elseif not toolbar[GUI.color_row] then
    destroy_if_valid(toolbar)
    toolbar = slot.add {
      type = "flow",
      name = GUI.toolbar,
      direction = "vertical"
    }
  end

  if toolbar and toolbar.valid then
    ensure_toolbar(toolbar, state)
  end

  local style_row = toolbar[GUI.style_row]
  if not style_row then
    return
  end

  local slider_index = width_slider_index(state.style.width)
  local slider = style_row[GUI.width_slider]
  if math.floor(slider.slider_value + 0.5) ~= slider_index then
    slider.slider_value = slider_index
  end

  slider.tooltip = { "doodle-gui.width-slider-tooltip", state.style.width }
  style_row[GUI.width_value].caption = tostring(state.style.width)

  local color_row = toolbar[GUI.color_row]
  local color_dropdown = color_row and color_row[GUI.color_dropdown]
  if color_dropdown and color_dropdown.valid then
    local color_index = SettingValues.color_option_index(SettingValues.line_color_setting(player))
    if color_dropdown.selected_index ~= color_index then
      color_dropdown.selected_index = color_index
    end
  end

  local buttons = toolbar[GUI.buttons]
  if buttons and buttons.valid then
    local is_line_tool = state.active_tool_id == Constants.TOOL_LINE
    buttons.visible = is_line_tool
    if is_line_tool then
      local count = point_count(state)
      buttons[GUI.finish_button].enabled = count >= 2
      buttons[GUI.cancel_button].enabled = state.in_progress ~= nil
    end
  end
end

local function update_clear_confirm(slot, state)
  local confirm = slot[GUI.clear_confirm]

  if not state.clear_confirm_open then
    destroy_if_valid(confirm)
    return
  end

  destroy_if_valid(slot[GUI.toolbar])

  if not (confirm and confirm.valid) then
    confirm = slot.add {
      type = "flow",
      name = GUI.clear_confirm,
      direction = "vertical"
    }

    ensure_clear_confirm(confirm)
  end
end

function M.update(player)
  if not player or not player.valid or not player.gui then
    return
  end

  local state = PlayerState.get_player(player.index)
  local slot = get_extension_slot(player)

  if not slot then
    local panel = player.gui.screen[Constants.EMOF_PANEL_NAME]
    if panel and panel.valid then
      local extension_slot = panel[Constants.EMOF_EXTENSION_SLOT]
      destroy_if_valid(extension_slot and extension_slot[GUI.toolbar])
      destroy_if_valid(extension_slot and extension_slot[GUI.clear_confirm])
    end
    return
  end

  update_toolbar(player, slot, state)
  update_clear_confirm(slot, state)
  sync_slot_visibility(slot)
end

local function element_in_named_container(element, container_name)
  local container = element
  while container and container.valid and container.name ~= container_name do
    container = container.parent
  end

  if container and container.valid and container.name == container_name then
    return element.name
  end

  return false
end

function M.handle_click(event)
  local element = event.element
  if not element or not element.valid then
    return false
  end

  local button_name = element_in_named_container(element, GUI.toolbar)
  if button_name then
    return button_name
  end

  return element_in_named_container(element, GUI.clear_confirm)
end

function M.handle_selection_state_changed(event)
  local element = event.element
  if not element or not element.valid then
    return false
  end

  if element_in_named_container(element, GUI.toolbar) == GUI.color_dropdown then
    return GUI.color_dropdown
  end

  return false
end

function M.handle_value_changed(event)
  local element = event.element
  if not element or not element.valid then
    return false
  end

  if element_in_named_container(element, GUI.toolbar) == GUI.width_slider then
    return GUI.width_slider
  end

  return false
end

function M.width_from_slider_value(slider_value)
  local index = math.floor(slider_value + 0.5)
  index = math.max(1, math.min(index, #SettingValues.width_options()))
  return SettingValues.width_options()[index]
end

function M.color_from_dropdown_index(selected_index)
  return SettingValues.color_options()[selected_index]
end

return M
