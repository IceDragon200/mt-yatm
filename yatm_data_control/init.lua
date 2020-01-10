--
-- YATM Data Control
--
yatm_data_control = rawget(_G, "yatm_data_control") or {}
yatm_data_control.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_control.modpath .. "/api.lua")

dofile(yatm_data_control.modpath .. "/items.lua")
dofile(yatm_data_control.modpath .. "/nodes.lua")
