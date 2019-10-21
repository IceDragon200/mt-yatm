yatm_cluster_energy = rawget(_G, "yatm_cluster_energy") or {}
yatm_cluster_energy.modpath = minetest.get_modpath(minetest.get_current_modname())

-- Node Utilities
dofile(yatm_cluster_energy.modpath .. "/energy_devices.lua")
-- Networks
dofile(yatm_cluster_energy.modpath .. "/energy.lua")

dofile(yatm_cluster_energy.modpath .. "/api.lua")

dofile(yatm_cluster_energy.modpath .. "/energy_system.lua")
dofile(yatm_cluster_energy.modpath .. "/energy_cluster.lua")
dofile(yatm_cluster_energy.modpath .. "/hooks.lua")

dofile(yatm_cluster_energy.modpath .. "/tests.lua")
