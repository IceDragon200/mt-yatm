--[[
YATM Item Shelves
]]
yatm_item_shelves = rawget(_G, "yatm_item_shelves") or {}
yatm_item_shelves.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_item_shelves.modpath .. "/api.lua")

dofile(yatm_item_shelves.modpath .. "/nodes.lua")

dofile(yatm_item_shelves.modpath .. "/tests.lua")
