local M = {}

M.CURSOR_LINE = "doodle-line-cursor"
M.CURSOR_ARROW = "doodle-arrow-cursor"
M.CURSOR_SQUARE = "doodle-square-cursor"
M.CURSOR_CIRCLE = "doodle-circle-cursor"
M.CURSOR_ERASER = "doodle-eraser-cursor"

M.INPUT_UNDO = "doodle-undo"
M.INPUT_REDO = "doodle-redo"

M.OWNER = "doodle"
M.MAP_TOOL_INTERFACE = "doodle_map_tool"
M.EMOF_INTERFACE_NAME = "extensible_map_overlay_framework"
M.EMOF_PANEL_NAME = "emof_map_panel"
M.EMOF_EXTENSION_SLOT = "emof_extension_slot"
M.EMOF_ACTION_CLICKED_EVENT = "emof-on-map-action-clicked"
M.EMOF_TOOL_STATE_CHANGED_EVENT = "emof-on-tool-state-changed"

M.MAP_ACTIONS_INTERFACE = "doodle_map_actions"

M.ACTION_LINE_TOOL = "doodle-line-action"
M.ACTION_ARROW_TOOL = "doodle-arrow-action"
M.ACTION_SQUARE_TOOL = "doodle-square-action"
M.ACTION_CIRCLE_TOOL = "doodle-circle-action"
M.ACTION_ERASER_TOOL = "doodle-eraser-action"
M.ACTION_CLEAR_ALL = "doodle-clear-action"
M.ACTION_UNDO = "doodle-undo-action"
M.ACTION_REDO = "doodle-redo-action"

M.TOOL_LINE = "doodle-line-tool"
M.TOOL_ARROW = "doodle-arrow-tool"
M.TOOL_SQUARE = "doodle-square-tool"
M.TOOL_CIRCLE = "doodle-circle-tool"
M.TOOL_ERASER = "doodle-eraser-tool"

M.DOODLE_TYPE_POLYLINE = "polyline"
M.DOODLE_TYPE_ARROW = "arrow"
M.DOODLE_TYPE_RECTANGLE = "rectangle"
M.DOODLE_TYPE_CIRCLE = "circle"

M.CONTROL_POINT_RADIUS = 0.3
M.MIN_CIRCLE_RADIUS = 0.1
M.ERASER_TOLERANCE_BASE = 0.25
M.RENDER_REPAIR_INTERVAL = 60

M.GUI = {
  toolbar = "doodle_toolbar",
  clear_confirm = "doodle_clear_confirm",
  style_row = "style_row",
  color_row = "color_row",
  width_label = "width_label",
  width_slider = "width_slider",
  width_value = "width_value",
  color_label = "color_label",
  color_dropdown = "color_dropdown",
  buttons = "buttons",
  finish_button = "finish_button",
  cancel_button = "cancel_button",
  clear_confirm_label = "clear_confirm_label",
  confirm_buttons = "confirm_buttons",
  clear_confirm_button = "clear_confirm_button",
  clear_cancel_button = "clear_cancel_button"
}

M.DEACTIVATE_REASON = {
  toolbar_toggle = "toolbar-toggle",
  line_cancelled = "line-cancelled",
  chart_controls_closed = "chart-controls-closed",
  tool_ended = "tool-ended",
  clear_action = "clear-action",
  disconnect = "disconnect",
  force_changed = "force-changed",
  doodle_cancel = "doodle-cancel"
}

return M
