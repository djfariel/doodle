-- Multi-point line geometry helpers for line_tool (preview, append, finish, cancel).

local Actions = require("scripts.actions")
local Constants = require("scripts.constants")
local Preview = require("scripts.preview")
local PlayerState = require("scripts.player_state")
local RenderAudience = require("scripts.render_audience")
local ToolUtil = require("scripts.tools.tool_util")
local Util = require("scripts.util")

local M = {}

local function ensure_preview(state)
  if not state.preview then
    state.preview = Preview.create()
  end

  return state.preview
end

function M.redraw_preview(player, state)
  local in_progress = state.in_progress
  local preview = ensure_preview(state)

  if not in_progress or in_progress.tool_id ~= Constants.TOOL_LINE or #in_progress.points == 0 then
    Preview.destroy(preview)
    return
  end

  local surface = game.surfaces[in_progress.surface_index]
  if not surface or not surface.valid then
    return
  end

  Preview.redraw(preview, surface, in_progress.points, state.style, RenderAudience.for_preview(player))
end

function M.append_point(player, state, position, surface)
  if not state.in_progress then
    state.in_progress = {
      tool_id = Constants.TOOL_LINE,
      points = { Util.copy_position(position) },
      surface_index = surface.index
    }
    M.redraw_preview(player, state)
    return
  end

  if not ToolUtil.same_surface_or_warn(player, state.in_progress, surface) then
    return
  end

  local points = state.in_progress.points
  points[#points + 1] = Util.copy_position(position)
  M.redraw_preview(player, state)
end

function M.try_finish(player)
  local state = PlayerState.get_player(player.index)
  local in_progress = state.in_progress

  if not in_progress or #in_progress.points < 2 then
    return false
  end

  local surface = game.surfaces[in_progress.surface_index]
  if not surface or not surface.valid then
    return false
  end

  local doodle = Actions.create_polyline(player, in_progress.points, surface)
  if not doodle then
    return false
  end

  ToolUtil.clear_in_progress(state)
  player.print({ "doodle-message.line-committed", #doodle.geometry.points })
  return true
end

function M.cancel(player, state)
  if not state.in_progress then
    return
  end

  ToolUtil.clear_in_progress(state)
  player.print({ "doodle-message.line-cancelled" })
end

return M
