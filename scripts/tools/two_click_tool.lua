-- Factory for two-click shape tools (arrow, square, circle).

local Constants = require("scripts.constants")
local Gui = require("scripts.gui")
local PlayerState = require("scripts.player_state")
local RenderAudience = require("scripts.render_audience")
local ToolUtil = require("scripts.tools.tool_util")

local M = {}

local GUI = Constants.GUI

function M.build(spec)
  local tool = {}

  tool.tool_id = spec.tool_id
  tool.action_id = spec.action_id

  local function redraw_preview(player, state)
    local in_progress = state.in_progress
    if not in_progress or in_progress.tool_id ~= spec.tool_id then
      return
    end

    local surface = game.surfaces[in_progress.surface_index]
    if not surface or not surface.valid then
      return
    end

    spec.redraw_preview(
      state.preview,
      surface,
      in_progress,
      state.style,
      RenderAudience.for_preview(player)
    )
  end

  function tool.map_tool_spec()
    return ToolUtil.base_map_tool_spec(
      spec.tool_id,
      spec.order,
      spec.locale_key,
      spec.cursor_item
    )
  end

  function tool.is_active(state)
    return state.active_tool_id == spec.tool_id
  end

  function tool.activate(player, surface_index)
    ToolUtil.activate_tool(player, surface_index, spec.tool_id)
  end

  function tool.deactivate(player, reason)
    ToolUtil.deactivate_tool(player, spec.tool_id, reason)
  end

  function tool.on_map_click(event)
    local player = game.get_player(event.player_index)
    if not player then
      return "continue"
    end

    local state = PlayerState.get_player(player.index)
    if not tool.is_active(state) then
      return "continue"
    end

    local position, surface = ToolUtil.resolve_click(player, event)
    if not position then
      return "continue"
    end

    if event.surface_index then
      state.tool_surface_index = event.surface_index
    end

    local in_progress = state.in_progress
    if not in_progress or in_progress.tool_id ~= spec.tool_id then
      state.in_progress = spec.begin_in_progress(position, surface.index)
      redraw_preview(player, state)
      Gui.update(player)
      return "continue"
    end

    if not ToolUtil.same_surface_or_warn(player, in_progress, surface) then
      return "continue"
    end

    if spec.validate_commit and not spec.validate_commit(player, in_progress, position, surface) then
      return "continue"
    end

    local doodle = spec.commit(player, in_progress, position, surface)
    if doodle then
      ToolUtil.clear_in_progress(state)
      player.print(spec.committed_message)
    end

    Gui.update(player)
    return "continue"
  end

  function tool.on_style_changed(player, state)
    redraw_preview(player, state)
  end

  function tool.handle_toolbar_control(player, control_name, event)
    if control_name == GUI.width_slider then
      local state = PlayerState.get_player(player.index)
      ToolUtil.handle_width_slider(player, state, redraw_preview, event.element.slider_value)
      return true
    end

    return false
  end

  return tool
end

return M
