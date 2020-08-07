local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local table_length = assert(foundation.com.table_length)
local DIR6_TO_VEC3 = assert(foundation.com.Directions.DIR6_TO_VEC3)

local EnergyCluster = yatm_clusters.SimpleCluster:extends("EnergyCluster")
local ic = EnergyCluster.instance_class

function ic:initialize(cluster_group)
  ic._super.initialize(self, {
    cluster_group = cluster_group,
    log_group = 'yatm.cluster.energy',
    node_group = 'yatm_cluster_energy'
  })
end

function ic:get_node_infotext(pos)
  local node_id = minetest.hash_node_position(pos)

  return yatm.clusters:reduce_node_clusters(pos, '', function (cluster, acc)
    if cluster.groups[self.m_cluster_group] then
      return false, "Energy Cluster: " .. cluster.id
    else
      return true, acc
    end
  end)
end

function ic:get_node_groups(node)
  local nodedef = minetest.registered_nodes[node.name]
  if not nodedef.yatm_network.groups then
    error("node=" .. node.name .. " is missing its groups")
  end
  return nodedef.yatm_network.groups
end

yatm_cluster_energy.EnergyCluster = EnergyCluster
