--
-- YATM Data Logic
--
yatm_data_logic = rawget(_G, "yatm_data_logic") or {}
yatm_data_logic.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_logic.modpath .. "/nodes.lua")
dofile(yatm_data_logic.modpath .. "/items.lua")
