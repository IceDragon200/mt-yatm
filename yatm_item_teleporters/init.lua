--
-- YATM Item Teleporters
--
yatm_item_teleporters = rawget(_G, "yatm_item_teleporters") or {}
yatm_item_teleporters.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_item_teleporters.modpath .. "/nodes.lua")
