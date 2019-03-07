--[[
YATM Foundry, provides the Blast Furnace (and it's mini counterpart), as well as
other metal processing nodes.
]]
yatm_foundry = rawget(_G, "yatm_foundry") or {}
yatm_foundry.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_foundry.modpath .. "/nodes.lua")
dofile(yatm_foundry.modpath .. "/items.lua")
