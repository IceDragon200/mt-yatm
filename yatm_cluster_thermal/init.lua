yatm_cluster_thermal = rawget(_G, "yatm_cluster_thermal") or {}
yatm_cluster_thermal.modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(yatm_cluster_thermal.modpath .. "/thermal_system.lua")
dofile(yatm_cluster_thermal.modpath .. "/thermal_cluster.lua")
dofile(yatm_cluster_thermal.modpath .. "/api.lua")
dofile(yatm_cluster_thermal.modpath .. "/hooks.lua")

dofile(yatm_cluster_thermal.modpath .. "/nodes.lua")

dofile(yatm_cluster_thermal.modpath .. "/tests.lua")
