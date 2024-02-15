--[[

  Public API exposed by YATM Clusters

]]

--
-- Functions
--
--- @spec yatm.queue_refresh_infotext(pos: Vector3, node: NodeRef, params: Any): void
yatm.queue_refresh_infotext = assert(yatm_clusters.queue_refresh_infotext)
yatm.explore_nodes = assert(yatm_clusters.explore_nodes)

--
-- Modules
--
--- @const yatm.Clusters = yatm_clusters.Clusters
yatm.Clusters = assert(yatm_clusters.Clusters)

--- @const yatm_clusters.clusters: yatm_clusters.Clusters
yatm_clusters.clusters = yatm.Clusters:new{
  world = minetest,
}

--- @const yatm.clusters: yatm_clusters.Clusters
yatm.clusters = assert(yatm_clusters.clusters)

local clusters = assert(yatm.clusters)
local is_table_empty = assert(foundation.com.is_table_empty)

local cluster_tool = {
  lookup_functions = {},
  render_functions = {},
}

function cluster_tool.register_cluster_tool_render(name, callback)
  if cluster_tool.render_functions[name] then
    error("cluster_tool lookup of id=" .. id .. " already exist!")
  end
  cluster_tool.render_functions[name] = callback
end

function cluster_tool.register_cluster_tool_lookup(id, callback)
  if cluster_tool.lookup_functions[id] then
    error("cluster_tool lookup of id=" .. id .. " already exist!")
  end
  cluster_tool.lookup_functions[id] = callback
end

function cluster_tool.lookup_clusters(pos, state)
  for _id, func in pairs(cluster_tool.lookup_functions) do
    func(pos, state)
  end
  return state
end

yatm.cluster_tool = cluster_tool

yatm.cluster = yatm.cluster or {}

--
-- Classes
--
yatm.transport = yatm.transport or {}
yatm.transport.GenericTransportNetwork = assert(yatm_clusters.GenericTransportNetwork)

