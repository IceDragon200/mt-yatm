--
-- YATM Plastics
--
yatm_plastics = rawget(_G, "yatm_plastics") or {}
yatm_plastics.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_plastics.modpath .. "/nodes.lua")
