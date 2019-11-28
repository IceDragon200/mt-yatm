--
-- YATM Security
--
yatm_security = rawget(_G, "yatm_security") or {}
yatm_security.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_security.modpath .. "/util.lua")

dofile(yatm_security.modpath .. "/items.lua")
dofile(yatm_security.modpath .. "/nodes.lua")
