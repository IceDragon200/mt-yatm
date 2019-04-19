--[[
YATM Armoury

Offers weapons, armor and other items geared towards fights
]]
yatm_armoury = rawget(_G, "yatm_armoury") or {}
yatm_armoury.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_armoury.modpath .. "/api.lua")

dofile(yatm_armoury.modpath .. "/nodes.lua")
dofile(yatm_armoury.modpath .. "/items.lua")
