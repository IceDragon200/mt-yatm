--
-- YATM Data Logic
--
yatm_data_logic = rawget(_G, "yatm_data_logic") or {}
yatm_data_logic.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_logic.modpath .. "/common.lua")

dofile(yatm_data_logic.modpath .. "/nodes.lua")
dofile(yatm_data_logic.modpath .. "/items.lua")

dofile(yatm_data_logic.modpath .. "/migrations.lua")

dofile(yatm_data_logic.modpath .. "/tests.lua")
