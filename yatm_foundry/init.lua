--
-- YATM Foundry
--
--[[
provides the Blast Furnace (and it's mini counterpart), as well as
other metal processing nodes.

If you're looking for stone processing, check yatm_stonecraft.
If you're looking for wood processing, check yatm_woodcraft.
]]
local mod = foundation.new_module("yatm_foundry", "1.0.0")

mod:require("kiln_registry.lua")
mod:require("blasting_registry.lua")
mod:require("smelting_registry.lua")
mod:require("molding_registry.lua")

mod:require("api.lua")

mod:require("nodes.lua")
mod:require("items.lua")
mod:require("fluids.lua")

mod:require("recipes.lua")

mod:require("migrations.lua")

mod:require("tests.lua")
