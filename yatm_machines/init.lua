--
-- YATM Machines
--
yatm_machines = rawget(_G, "yatm_machines") or {}
yatm_machines.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_machines.modpath .. "/nodes.lua")
