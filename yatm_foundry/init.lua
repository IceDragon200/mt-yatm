--
-- YATM Foundry
--
--[[
provides the Blast Furnace (and it's mini counterpart), as well as
other metal processing nodes.

If you're looking for stone processing, check yatm_stonecraft.
If you're looking for wood processing, check yatm_woodcraft.
]]
yatm_foundry = rawget(_G, "yatm_foundry") or {}
yatm_foundry.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_foundry.modpath .. "/kiln_registry.lua")
dofile(yatm_foundry.modpath .. "/blasting_registry.lua")
dofile(yatm_foundry.modpath .. "/smelting_registry.lua")
dofile(yatm_foundry.modpath .. "/molding_registry.lua")

dofile(yatm_foundry.modpath .. "/api.lua")

dofile(yatm_foundry.modpath .. "/nodes.lua")
dofile(yatm_foundry.modpath .. "/items.lua")
dofile(yatm_foundry.modpath .. "/fluids.lua")

dofile(yatm_foundry.modpath .. "/recipes.lua")

dofile(yatm_foundry.modpath .. "/tests.lua")
