--
-- YATM Clusters
--
-- Handles node registration and general house keeping of node clusters.
--
yatm_clusters = rawget(_G, "yatm_clusters") or {}
yatm_clusters.modpath = minetest.get_modpath(minetest.get_current_modname())

-- Networks
dofile(yatm_clusters.modpath .. "/clusters.lua")
dofile(yatm_clusters.modpath .. "/node_tracing.lua")
dofile(yatm_clusters.modpath .. "/generic_transport_network.lua")
dofile(yatm_clusters.modpath .. "/network.lua")

dofile(yatm_clusters.modpath .. "/util/infotext.lua")

dofile(yatm_clusters.modpath .. "/api.lua")

dofile(yatm_clusters.modpath .. "/hooks.lua")
