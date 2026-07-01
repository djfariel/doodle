-- Integration test entry point for this mod
-- Called from integration-runner.sh via Factorio scenario
-- Usage: require("run-tests").run(mod_root, factorio_player_data)

local mod_root = ...
local factorio_player_data = ...

-- Set up package.path so require("testing.integration") and require("testing.assertions") work
package.path = table.concat({
  mod_root .. "/?.lua",
  mod_root .. "/?/init.lua",
  mod_root .. "/scripts/?.lua",
  mod_root .. "/../testing/lua/?.lua",
  package.path
}, ";")

local integration = require("testing.integration")
integration.run(mod_root, factorio_player_data)
