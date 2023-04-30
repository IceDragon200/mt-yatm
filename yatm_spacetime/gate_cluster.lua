local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local table_length = assert(foundation.com.table_length)
local DIR6_TO_VEC3 = assert(foundation.com.Directions.DIR6_TO_VEC3)

--- @class GateCluster
local GateCluster = yatm_clusters.SimpleCluster:extends("GateCluster")
do
  local ic = assert(GateCluster.instance_class)

  -- @spec #initialize(cluster_group: String): void
  function ic:initialize(cluster_group)
    ic._super.initialize(self, {
      cluster_group = cluster_group,
      log_group = "yatm.cluster.gate",
      node_group = "yatm_cluster_gate"
    })
  end

  --- @spec #get_node_infotext(pos: Vector3): String
  function ic:get_node_infotext(pos)
    local node_id = minetest.hash_node_position(pos)

    return yatm.clusters:reduce_node_clusters(pos, "", function (cluster, acc)
      if cluster.groups[self.m_cluster_group] then
        return false, "Gateway Cluster: " .. cluster.id
      else
        return true, acc
      end
    end)
  end

  --- @spec #get_controller_at(pos: Vector3): Table
  function ic:get_controller_at(pos)
    return yatm.clusters:reduce_node_clusters(pos, nil, function (cluster, acc)
      if cluster.groups[self.m_cluster_group] then
        return false, cluster:reduce_nodes_of_group("gate_controller", nil, function (entry, acc)
          return false, entry
        end)
      else
        return true, acc
      end
    end)
  end

  --- @spec #get_node_groups(node: NodeRef): Table
  function ic:get_node_groups(node)
    local nodedef = minetest.registered_nodes[node.name]

    if nodedef and nodedef.yatm_spacetime then
      return nodedef.yatm_spacetime.groups or {}
    end

    return {}
  end

end

yatm_spacetime.GateCluster = GateCluster
