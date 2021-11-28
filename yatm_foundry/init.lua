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

yatm_foundry.blasting_registry = yatm_foundry.BlastingRegistry:new()
yatm_foundry.molding_registry = yatm_foundry.MoldingRegistry:new()
yatm_foundry.kiln_registry = yatm_foundry.KilnRegistry:new()
yatm_foundry.smelting_registry = yatm_foundry.SmeltingRegistry:new()

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")
mod:require("fluids.lua")

mod:require("recipes.lua")

mod:require("migrations.lua")

mod:require("tests.lua")
