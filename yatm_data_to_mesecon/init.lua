--
-- YATM Data To Mesecon
--
-- Adds additional nodes for transforming from mesecon signals to data messages and vice versa
yatm_data_to_mesecon = rawget(_G, "yatm_data_to_mesecon") or {}
yatm_data_to_mesecon.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_to_mesecon.modpath .. "/nodes.lua")
