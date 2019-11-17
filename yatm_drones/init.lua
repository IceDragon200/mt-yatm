--
--
--
yatm_drones = rawget(_G, "yatm_drones") or {}
yatm_drones.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_drones.modpath .. "/entities.lua")
dofile(yatm_drones.modpath .. "/items.lua")
dofile(yatm_drones.modpath .. "/nodes.lua")
