--[[
YATM Item Storage
]]
yatm_item_storage = rawget(_G, "yatm_item_storage") or {}
yatm_item_storage.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_item_storage.modpath .. "/nodes.lua")