--
-- YATM Data Display
--
yatm_data_display = rawget(_G, "yatm_data_display") or {}
yatm_data_display.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_display.modpath .. "/nodes.lua")
dofile(yatm_data_display.modpath .. "/items.lua")
