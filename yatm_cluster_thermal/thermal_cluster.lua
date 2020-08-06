local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local table_length = assert(foundation.com.table_length)
local DIR6_TO_VEC3 = assert(foundation.com.Directions.DIR6_TO_VEC3)

local ThermalCluster = yatm_clusters.SimpleCluster:extends("ThermalCluster")
local ic = ThermalCluster.instance_class

function ic:initialize(cluster_group)
  ic._super.initialize(self, {
    cluster_group = cluster_group,
    log_group = 'yatm.cluster.thermal',
    node_group = 'yatm_cluster_thermal'
  })
end

function ic:get_node_infotext(pos)
  local node_id = minetest.hash_node_position(pos)

  return yatm.clusters:reduce_node_clusters(pos, '', function (cluster, acc)
    if cluster.groups[self.m_cluster_group] then
      return false, "Thermal Cluster: " .. cluster.id
    else
      return true, acc
    end
  end)
end

function ic:get_node_groups(node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.thermal_interface then
    return assert(nodedef.thermal_interface.groups)
  end
  return {}
end

yatm_cluster_thermal.ThermalCluster = ThermalCluster
