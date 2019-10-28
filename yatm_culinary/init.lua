--
-- YATM Culinary
--
yatm_culinary = rawget(_G, "yatm_culinary") or {}
yatm_culinary.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_culinary.modpath .. "/nodes.lua")
