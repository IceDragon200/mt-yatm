--
-- YATM Bees
--
yatm_bees = rawget(_G, "yatm_bees") or {}
yatm_bees.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_bees.modpath .. "/nodes.lua")
