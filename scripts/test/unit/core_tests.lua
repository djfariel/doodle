local assertions = require("assertions")
local describe = assertions.describe
local it = assertions.it
local assert = assertions.assert
local geometry = require("scripts.geometry")

describe("geometry.distance", function()
  it("returns 0 for identical points", function(context)
    local a = { x = 1, y = 2 }
    local b = { x = 1, y = 2 }
    assert.equal(0, geometry.distance(a, b))
  end)

  it("returns correct distance for axis-aligned horizontal points", function(context)
    local a = { x = 0, y = 0 }
    local b = { x = 3, y = 0 }
    assert.near(3, geometry.distance(a, b))
  end)

  it("returns correct distance for axis-aligned vertical points", function(context)
    local a = { x = 0, y = 0 }
    local b = { x = 0, y = 4 }
    assert.near(4, geometry.distance(a, b))
  end)

  it("returns correct distance for diagonal points (3-4-5 triangle)", function(context)
    local a = { x = 0, y = 0 }
    local b = { x = 3, y = 4 }
    assert.near(5, geometry.distance(a, b))
  end)

  it("returns correct distance for negative coordinates", function(context)
    local a = { x = -1, y = -1 }
    local b = { x = 1, y = 1 }
    assert.near(2.828427, geometry.distance(a, b), 0.001)
  end)
end)

describe("geometry.distance_to_segment", function()
  it("returns 0 when point is on the segment", function(context)
    local point = { x = 1, y = 1 }
    local from = { x = 0, y = 0 }
    local to = { x = 2, y = 2 }
    assert.near(0, geometry.distance_to_segment(point, from, to))
  end)

  it("returns correct perpendicular distance to segment", function(context)
    local point = { x = 0, y = 1 }
    local from = { x = 0, y = 0 }
    local to = { x = 2, y = 0 }
    assert.near(1, geometry.distance_to_segment(point, from, to))
  end)

  it("returns distance to nearest endpoint when point projects outside segment", function(context)
    local point = { x = 3, y = 0 }
    local from = { x = 0, y = 0 }
    local to = { x = 2, y = 0 }
    assert.near(1, geometry.distance_to_segment(point, from, to))
  end)

  it("handles zero-length segment (from == to)", function(context)
    local point = { x = 3, y = 4 }
    local from = { x = 0, y = 0 }
    local to = { x = 0, y = 0 }
    assert.near(5, geometry.distance_to_segment(point, from, to))
  end)

  it("returns distance to endpoint when point is perpendicular outside segment range", function(context)
    local point = { x = -1, y = 0 }
    local from = { x = 0, y = 0 }
    local to = { x = 2, y = 0 }
    assert.near(1, geometry.distance_to_segment(point, from, to))
  end)
end)

describe("geometry.min_distance_to_polyline", function()
  it("returns huge for empty points", function(context)
    assert.equal(math.huge, geometry.min_distance_to_polyline({ x = 0, y = 0 }, {}))
  end)

  it("returns huge for single point", function(context)
    assert.equal(math.huge, geometry.min_distance_to_polyline({ x = 0, y = 0 }, { { x = 1, y = 1 } }))
  end)

  it("returns 0 when point lies on a polyline segment", function(context)
    local point = { x = 1, y = 0 }
    local points = { { x = 0, y = 0 }, { x = 2, y = 0 } }
    assert.near(0, geometry.min_distance_to_polyline(point, points))
  end)

  it("returns correct minimum distance to polyline", function(context)
    local point = { x = 0, y = 1 }
    local points = { { x = 0, y = 0 }, { x = 2, y = 0 } }
    assert.near(1, geometry.min_distance_to_polyline(point, points))
  end)
end)

describe("geometry.normalize_rect_corners", function()
  it("normalizes when left_top is already smaller", function(context)
    local a = { x = 0, y = 0 }
    local b = { x = 5, y = 5 }
    local result = geometry.normalize_rect_corners(a, b)
    assert.equal(0, result.left_top.x)
    assert.equal(0, result.left_top.y)
    assert.equal(5, result.right_bottom.x)
    assert.equal(5, result.right_bottom.y)
  end)

  it("swaps when a is larger than b", function(context)
    local a = { x = 5, y = 5 }
    local b = { x = 0, y = 0 }
    local result = geometry.normalize_rect_corners(a, b)
    assert.equal(0, result.left_top.x)
    assert.equal(0, result.left_top.y)
    assert.equal(5, result.right_bottom.x)
    assert.equal(5, result.right_bottom.y)
  end)

  it("handles mixed positive/negative coordinates", function(context)
    local a = { x = -3, y = -1 }
    local b = { x = 2, y = 4 }
    local result = geometry.normalize_rect_corners(a, b)
    assert.equal(-3, result.left_top.x)
    assert.equal(-1, result.left_top.y)
    assert.equal(2, result.right_bottom.x)
    assert.equal(4, result.right_bottom.y)
  end)
end)

describe("geometry.distance_to_rect_edges", function()
  it("returns distance when point is outside rectangle", function(context)
    local point = { x = 5, y = 1 }
    local left_top = { x = 0, y = 0 }
    local right_bottom = { x = 3, y = 3 }
    assert.near(2, geometry.distance_to_rect_edges(point, left_top, right_bottom))
  end)

  it("returns distance when point is inside rectangle", function(context)
    local point = { x = 1, y = 1 }
    local left_top = { x = 0, y = 0 }
    local right_bottom = { x = 5, y = 5 }
    assert.near(1, geometry.distance_to_rect_edges(point, left_top, right_bottom))
  end)

  it("returns 0 when point is on the edge", function(context)
    local point = { x = 0, y = 1 }
    local left_top = { x = 0, y = 0 }
    local right_bottom = { x = 5, y = 5 }
    assert.near(0, geometry.distance_to_rect_edges(point, left_top, right_bottom))
  end)

  it("returns correct diagonal distance when point is at corner outside", function(context)
    local point = { x = -1, y = -1 }
    local left_top = { x = 0, y = 0 }
    local right_bottom = { x = 5, y = 5 }
    assert.near(1.414214, geometry.distance_to_rect_edges(point, left_top, right_bottom), 0.001)
  end)
end)

describe("geometry.distance_to_circle", function()
  it("returns 0 when point is on the circle edge", function(context)
    local point = { x = 5, y = 0 }
    local center = { x = 0, y = 0 }
    local radius = 5
    assert.near(0, geometry.distance_to_circle(point, center, radius))
  end)

  it("returns correct distance when point is inside circle", function(context)
    local point = { x = 2, y = 0 }
    local center = { x = 0, y = 0 }
    local radius = 5
    assert.near(3, geometry.distance_to_circle(point, center, radius))
  end)

  it("returns correct distance when point is outside circle", function(context)
    local point = { x = 10, y = 0 }
    local center = { x = 0, y = 0 }
    local radius = 5
    assert.near(5, geometry.distance_to_circle(point, center, radius))
  end)

  it("handles non-axis-aligned point on circle", function(context)
    local point = { x = 3, y = 4 }
    local center = { x = 0, y = 0 }
    local radius = 5
    assert.near(0, geometry.distance_to_circle(point, center, radius))
  end)
end)
