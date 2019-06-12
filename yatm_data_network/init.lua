--
-- YATM Data Network
--
yatm_data_network = rawget(_G, "yatm_data_network") or {}
yatm_data_network.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_network.modpath .. "/data_network.lua")

dofile(yatm_data_network.modpath .. "/api.lua")

dofile(yatm_data_network.modpath .. "/nodes.lua")
