--
-- YATM Rails
--
yatm_rails = rawget(_G, "yatm_rails") or {}
yatm_rails.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_rails.modpath .. "/api.lua")

dofile(yatm_rails.modpath .. "/entities.lua")
dofile(yatm_rails.modpath .. "/nodes.lua")
dofile(yatm_rails.modpath .. "/items.lua")

dofile(yatm_rails.modpath .. "/tests.lua")
