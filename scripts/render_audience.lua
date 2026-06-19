--- Rendering audience helpers.
---
--- Committed doodles use force targeting so teammates see annotations in MP and
--- renders survive when no force members are connected. In-progress previews
--- use player targeting so only the drawer sees unfinished geometry.

local M = {}

function M.for_doodle(doodle)
  return { forces = { doodle.owner_force_name } }
end

function M.for_preview(player)
  return { players = { player.index } }
end

return M
