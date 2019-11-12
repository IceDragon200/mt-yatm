--
-- Mining is focused on automated mining tools, such as the surface drill and quarry.
--
yatm_mining = rawget(_G, "yatm_mining") or {}
yatm_mining.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_mining.modpath .. "/api.lua")

dofile(yatm_mining.modpath .. "/nodes.lua")

dofile(yatm_mining.modpath .. "/tests.lua")
