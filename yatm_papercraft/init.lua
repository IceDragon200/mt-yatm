--
-- YATM Papercraft
--
yatm_papercraft = rawget(_G, "yatm_papercraft") or {}
yatm_papercraft.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_papercraft.modpath .. "/nodes.lua")
dofile(yatm_papercraft.modpath .. "/items.lua")
