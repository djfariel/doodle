local M = {}

function M.distance(a, b)
  local dx = a.x - b.x
  local dy = a.y - b.y
  return math.sqrt(dx * dx + dy * dy)
end

function M.distance_to_segment(point, from, to)
  local dx = to.x - from.x
  local dy = to.y - from.y
  local length_squared = dx * dx + dy * dy

  if length_squared == 0 then
    return M.distance(point, from)
  end

  local t = ((point.x - from.x) * dx + (point.y - from.y) * dy) / length_squared
  t = math.max(0, math.min(1, t))

  local closest = {
    x = from.x + t * dx,
    y = from.y + t * dy
  }

  return M.distance(point, closest)
end

function M.min_distance_to_polyline(point, points)
  if not points or #points < 2 then
    return math.huge
  end

  local min_distance = math.huge
  for index = 2, #points do
    local distance = M.distance_to_segment(point, points[index - 1], points[index])
    if distance < min_distance then
      min_distance = distance
    end
  end

  return min_distance
end

function M.normalize_rect_corners(a, b)
  return {
    left_top = {
      x = math.min(a.x, b.x),
      y = math.min(a.y, b.y)
    },
    right_bottom = {
      x = math.max(a.x, b.x),
      y = math.max(a.y, b.y)
    }
  }
end

function M.distance_to_rect_edges(point, left_top, right_bottom)
  local inside_x = point.x >= left_top.x and point.x <= right_bottom.x
  local inside_y = point.y >= left_top.y and point.y <= right_bottom.y

  if inside_x and inside_y then
    local to_left = point.x - left_top.x
    local to_right = right_bottom.x - point.x
    local to_top = point.y - left_top.y
    local to_bottom = right_bottom.y - point.y
    return math.min(to_left, to_right, to_top, to_bottom)
  end

  local dx = 0
  if point.x < left_top.x then
    dx = left_top.x - point.x
  elseif point.x > right_bottom.x then
    dx = point.x - right_bottom.x
  end

  local dy = 0
  if point.y < left_top.y then
    dy = left_top.y - point.y
  elseif point.y > right_bottom.y then
    dy = point.y - right_bottom.y
  end

  return math.sqrt(dx * dx + dy * dy)
end

function M.distance_to_circle(point, center, radius)
  return math.abs(M.distance(point, center) - radius)
end

return M
