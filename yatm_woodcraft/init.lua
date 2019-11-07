--
-- YATM Woodcraft
--
--[[
Provides the Sawmill and other wood processing blocks
]]
yatm_woodcraft = rawget(_G, "yatm_woodcraft") or {}
yatm_woodcraft.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_woodcraft.modpath .. "/sawing_registry.lua")

dofile(yatm_woodcraft.modpath .. "/api.lua")

dofile(yatm_woodcraft.modpath .. "/nodes.lua")
dofile(yatm_woodcraft.modpath .. "/items.lua")

dofile(yatm_woodcraft.modpath .. "/recipes.lua")
