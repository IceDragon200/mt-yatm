--
-- YATM Fluid Teleporters
--
yatm_fluid_teleporters = rawget(_G, "yatm_fluid_teleporters") or {}
yatm_fluid_teleporters.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_fluid_teleporters.modpath .. "/nodes.lua")
