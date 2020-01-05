--
-- YATM Data Logic
--
yatm_data_noteblock = rawget(_G, "yatm_data_noteblock") or {}
yatm_data_noteblock.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_data_noteblock.modpath .. "/api.lua")

dofile(yatm_data_noteblock.modpath .. "/nodes.lua")
