local is_table_empty = yatm_core.is_table_empty
local table_keys = yatm_core.table_keys
local table_length = yatm_core.table_length
local DIR6_TO_VEC3 = yatm_core.DIR6_TO_VEC3

local ClusterEnergy = yatm_core.Class:extends("ClusterEnergy")
local ic = ClusterEnergy.instance_class

local CLUSTER_GROUP = 'yatm_energy'
local LOG_GROUP = 'yatm.cluster.energy'

function ic:initialize()
  --
end

function ic:terminate()
  print(LOG_GROUP, "terminated")
end

function ic:register_system(id, update)
  yatm.clusters:register_system(CLUSTER_GROUP, id, update)
end

function ic:get_node_infotext(pos)
  local node_id = minetest.hash_node_position(pos)

  return yatm.clusters:reduce_node_clusters(pos, '', function (cluster, acc)
    if cluster.groups[CLUSTER_GROUP] then
      return false, "Energy Cluster: " .. cluster.id
    else
      return true, acc
    end
  end)
end

function ic:get_node_energy_groups(node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.yatm_network then
    return nodedef.yatm_network.groups or {}
  else
    return {}
  end
end

function ic:schedule_add_node(pos, node)
  print(LOG_GROUP, 'schedule_add_node', minetest.pos_to_string(pos), node.name)
  local groups = self:get_node_energy_groups(node)
  yatm.clusters:schedule_node_event(CLUSTER_GROUP, 'add_node', pos, node, { groups = groups })
end

function ic:schedule_load_node(pos, node)
  print(LOG_GROUP, 'schedule_load_node', minetest.pos_to_string(pos), node.name)
  local groups = self:get_node_energy_groups(node)
  yatm.clusters:schedule_node_event(CLUSTER_GROUP, 'load_node', pos, node, { groups = groups })
end

function ic:schedule_update_node(pos, node)
  print(LOG_GROUP, 'schedule_update_node', minetest.pos_to_string(pos), node.name)
  local groups = self:get_node_energy_groups(node)
  yatm.clusters:schedule_node_event(CLUSTER_GROUP, 'update_node', pos, node, { groups = groups })
end

function ic:schedule_remove_node(pos, node)
  print(LOG_GROUP, 'schedule_remove_node', minetest.pos_to_string(pos), node.name)
  yatm.clusters:schedule_node_event(CLUSTER_GROUP, 'remove_node', pos, node, { })
end

function ic:handle_node_event(cls, generation_id, event, node_clusters)
  print(LOG_GROUP, 'event', event.event_name, generation_id, minetest.pos_to_string(event.pos))

  if event.event_name == 'load_node' then
    -- treat loads like adding a node
    self:_handle_add_node(cls, generation_id, event, node_clusters)

  elseif event.event_name == 'add_node' then
    self:_handle_add_node(cls, generation_id, event, node_clusters)

  elseif event.event_name == 'remove_node' then
    self:_handle_remove_node(cls, generation_id, event, node_clusters)

  else
    print(LOG_GROUP, "unhandled event event_name=" .. event.event_name)
  end
end

function ic:_handle_add_node(cls, generation_id, event, node_clusters)
  -- pull up all neighbouring nodes from the given clusters
  local neighbours = {}
  if node_clusters and not is_table_empty(node_clusters) then
    for dir6, vec3 in pairs(DIR6_TO_VEC3) do
      local npos = vector.add(event.pos, vec3)

      for cluster_id, _ in pairs(node_clusters) do
        local cluster = cls:get_cluster(cluster_id)
        if cluster then
          local node_entry = cluster:get_node(npos)

          if node_entry then
            neighbours[dir6] = {
              cluster_id = cluster_id,
              node_entry = node_entry
            }
            break
          end
        end
      end
    end
  end

  local cluster
  if is_table_empty(neighbours) then
    -- need a new cluster for this node
    cluster = cls:create_cluster({ [CLUSTER_GROUP] = 1 })
  else
    -- attempt to join an existing cluster
    local cluster_ids = {}
    for _dir6, neighbour in pairs(neighbours) do
      cluster_ids[neighbour.cluster_id] = true
    end
    cluster_ids = table_keys(cluster_ids)

    if #cluster_ids == 1 then
      -- join the cluster
      local cluster_id = cluster_ids[1]
      cluster = cls:get_cluster(cluster_id)
    else
      -- merge the clusters and then join
      cluster = cls:merge_clusters(cluster_ids)
    end
  end

  cls:add_node_to_cluster(cluster.id, event.pos, event.node, event.params.groups)

  cluster.assigns.generation_id = generation_id
end

function ic:_handle_remove_node(cls, generation_id, event, node_clusters)
  -- TODO:
  local cluster_id =
    cls:reduce_node_clusters(event.pos, nil, function (cluster, acc)
      if cluster.groups[CLUSTER_GROUP] then
        return false, cluster.id
      else
        return true, acc
      end
    end)

  if cluster_id then
    cls:remove_node_from_cluster(cluster_id, event.pos, event.node)
  end

  local all_nodes = {}
  local branch_nodes = {}
  local hash_node_position = minetest.hash_node_position
  local table_merge = yatm_core.table_merge
  local table_bury = yatm_core.table_bury

  local g_branch_id = 0
  for dir6, vec3 in pairs(DIR6_TO_VEC3) do
    g_branch_id = g_branch_id + 1
    local branch_id = g_branch_id
    local origin = vector.add(event.pos, vec3)
    local nodes = {}
    branch_nodes[branch_id] = nodes

    yatm.explore_nodes(origin, 0, function (pos, node, acc, accessible_dirs)
      local node_id = hash_node_position(pos)
      if nodes[node_id] then
        return false, acc
      end

      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.groups['yatm_cluster_energy'] then
          if all_nodes[node_id] then
            local other_branch_id = all_nodes[node_id]
            local other_branch_nodes = branch_nodes[other_branch_id]

            if nodes ~= other_branch_nodes then
              local new_nodes = {}
              table_merge(nodes, other_branch_nodes)
              for node_id,_ in pairs(nodes) do
                all_nodes[node_id] = other_branch_id
                new_nodes[node_id] = other_branch_id
              end
              for node_id,_ in pairs(other_branch_nodes) do
                all_nodes[node_id] = other_branch_id
                new_nodes[node_id] = other_branch_id
              end
              branch_nodes[other_branch_id] = new_nodes
              branch_nodes[branch_id] = nil
              branch_id = other_branch_id
              nodes = new_nodes
            end
          else
            all_nodes[node_id] = branch_id
            nodes[node_id] = branch_id
          end
          return true, acc + 1
        else
          return false, acc
        end
      else
        return false, acc
      end
    end)
  end

  local affected_clusters = {}
  local branch_id_to_cluster_id = {}
  for branch_id, nodes in pairs(branch_nodes) do
    for node_id, _ in pairs(nodes) do
      local pos = minetest.get_position_from_hash(node_id)

      local cluster_id =
        cls:reduce_node_clusters(pos, nil, function (cluster, acc)
          if cluster.groups[CLUSTER_GROUP] then
            return false, cluster.id
          else
            return true, acc
          end
        end)

      if cluster_id then
        affected_clusters[cluster_id] = true
        branch_id_to_cluster_id[branch_id] = cluster_id
        break
      end
    end
  end

  for cluster_id, _ in pairs(affected_clusters) do
    cls:destroy_cluster(cluster_id)
  end

  for branch_id, nodes in pairs(branch_nodes) do
    if not is_table_empty(nodes) then
      local cluster = cls:create_cluster({ [CLUSTER_GROUP] = 1 })

      for node_id, _ in pairs(nodes) do
        local pos = minetest.get_position_from_hash(node_id)
        local node = minetest.get_node(pos)

        cls:add_node_to_cluster(cluster.id, pos, node, self:get_node_energy_groups(node))
      end
    end
  end
end

yatm.cluster.energy = ClusterEnergy:new()
