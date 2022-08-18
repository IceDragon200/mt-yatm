--
-- YATM Foundry
--
-- provides the Blast Furnace (and it's mini counterpart), as well as
-- other metal processing nodes.
--
-- If you're looking for stone processing, check yatm_stonecraft.
-- If you're looking for wood processing, check yatm_woodcraft.
local mod = foundation.new_module("yatm_foundry", "2.0.0")

mod:require("registries/kiln_registry.lua")
mod:require("registries/blasting_registry.lua")
mod:require("registries/smelting_registry.lua")
mod:require("registries/molding_registry.lua")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")
mod:require("fluids.lua")

mod:require("recipes.lua")

mod:require("migrations.lua")

if minetest.global_exists("yatm_codex") then
  mod:require("codex.lua")
end

if minetest.global_exists("yatm_autotest") then
  mod:require("autotest.lua")
end

mod:require("tests.lua")
