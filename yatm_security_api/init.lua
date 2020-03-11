--
-- YATM Security API
--
yatm_security_api = rawget(_G, "yatm_security_api") or {}
yatm_security_api.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_security_api.modpath .. "/api.lua")
