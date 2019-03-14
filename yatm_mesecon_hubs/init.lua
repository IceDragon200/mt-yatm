--[[
YATM Mesecon Hubs
]]
yatm_mesecon_hubs = rawget(_G, "yatm_mesecon_hubs") or {}
yatm_mesecon_hubs.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mesecon_hubs.modpath .. "/network_meta.lua")
dofile(yatm_mesecon_hubs.modpath .. "/wireless_network.lua")
dofile(yatm_mesecon_hubs.modpath .. "/api.lua")

dofile(yatm_mesecon_hubs.modpath .. "/nodes.lua")
dofile(yatm_mesecon_hubs.modpath .. "/items.lua")

dofile(yatm_mesecon_hubs.modpath .. "/tests.lua")
