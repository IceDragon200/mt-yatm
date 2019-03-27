--[[
YATM Item Storage
]]
yatm_item_storage = rawget(_G, "yatm_item_storage") or {}
yatm_item_storage.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_item_storage.modpath .. "/item_interface.lua")
dofile(yatm_item_storage.modpath .. "/inventory_serializer.lua")
dofile(yatm_item_storage.modpath .. "/item_device.lua")

dofile(yatm_item_storage.modpath .. "/nodes.lua")

dofile(yatm_item_storage.modpath .. "/tests.lua")
