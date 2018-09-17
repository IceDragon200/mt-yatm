--
-- YATM Decor
--
yatm_decor = rawget(_G, "yatm_decor") or {}
yatm_decor.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_decor.modpath .. "/nodes.lua")
