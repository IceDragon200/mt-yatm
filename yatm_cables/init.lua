--
-- YATM Cables
--
yatm_cables = rawget(_G, "yatm_cables") or {}
yatm_cables.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_cables.modpath .. "/nodes.lua")
