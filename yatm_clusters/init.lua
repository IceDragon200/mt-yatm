--
-- YATM Clusters
--
-- Handles node registration and general house keeping of node clusters.
--
local mod = foundation.new_module("yatm_clusters", "1.1.0")

-- Networks
mod:require("clusters.lua")
mod:require("node_tracing.lua")

-- Utils
mod:require("util/infotext.lua")

-- Some network implementations
mod:require("generic_transport_network.lua")

-- API
mod:require("api.lua")

mod:require("simple_cluster.lua")

-- Items
mod:require("items/cluster_tool.lua")


-- Hooks
mod:require("hooks.lua")

