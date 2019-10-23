local is_table_empty = yatm_core.is_table_empty
local table_keys = yatm_core.table_keys
local table_length = yatm_core.table_length
local DIR6_TO_VEC3 = yatm_core.DIR6_TO_VEC3

local SimpleCluster = yatm_core.Class:extends("SimpleCluster")
local ic = SimpleCluster.instance_class

function ic:initialize(options)
  assert(type(options) == "table", "expected options to be a table")
  self.m_cluster_group = assert(options.cluster_group)
  self.m_node_group = assert(options.node_group)
  self.m_log_group = assert(options.log_group)
end

function ic:terminate()
  print(self.m_log_group, "terminated")
end

function ic:register_system(id, update)
  yatm.clusters:register_system(self.m_cluster_group, id, update)
end

function ic:get_node_infotext(pos)
  local node_id = minetest.hash_node_position(pos)

  return yatm.clusters:reduce_node_clusters(pos, '', function (cluster, acc)
    if cluster.groups[self.m_cluster_group] then
      return false, "Simple Cluster: " .. cluster.id
    else
      return true, acc
    end
  end)
end

function ic:get_node_groups(node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.simple_network then
    return nodedef.simple_network.groups or {}
  else
    return {}
  end
end

function ic:schedule_add_node(pos, node)
  print(self.m_log_group, 'schedule_add_node', minetest.pos_to_string(pos), node.name)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.groups[self.m_node_group] then
    local groups = self:get_node_groups(node)
    yatm.clusters:schedule_node_event(self.m_cluster_group, 'add_node', pos, node, { groups = groups })
  else
    error("node violation: " .. node.name .. " does not belong to " .. self.m_node_group .. " group")
  end
end

function ic:schedule_load_node(pos, node)
  print(self.m_log_group, 'schedule_load_node', minetest.pos_to_string(pos), node.name)
  local groups = self:get_node_groups(node)
  yatm.clusters:schedule_node_event(self.m_cluster_group, 'load_node', pos, node, { groups = groups })
end

function ic:schedule_update_node(pos, node)
  print(self.m_log_group, 'schedule_update_node', minetest.pos_to_string(pos), node.name)
  local groups = self:get_node_groups(node)
  yatm.clusters:schedule_node_event(self.m_cluster_group, 'update_node', pos, node, { groups = groups })
end

function ic:schedule_remove_node(pos, node)
  print(self.m_log_group, 'schedule_remove_node', minetest.pos_to_string(pos), node.name)
  yatm.clusters:schedule_node_event(self.m_cluster_group, 'remove_node', pos, node, { })
end

function ic:handle_node_event(cls, generation_id, event, cluster_ids)
  print(self.m_log_group, 'event', event.event_name, generation_id, minetest.pos_to_string(event.pos))

  if event.event_name == 'load_node' then
    -- treat loads like adding a node
    self:_handle_add_node(cls, generation_id, event, cluster_ids)

  elseif event.event_name == 'add_node' then
    self:_handle_add_node(cls, generation_id, event, cluster_ids)

  elseif event.event_name == 'update_node' then
    self:_handle_update_node(cls, generation_id, event, cluster_ids)

  elseif event.event_name == 'remove_node' then
    self:_handle_remove_node(cls, generation_id, event, cluster_ids)

  else
    print(self.m_log_group, "unhandled event event_name=" .. event.event_name)
  end
end

function ic:get_node_color(node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef.yatm_network then
    return nodedef.yatm_network.color or 'default'
  else
    return nil
  end
end

function ic:is_compatible_colors(a, b)
  if a == 'default' or b == 'default' then
    return true
  else
    return a == b
  end
end

function ic:find_compatible_neighbours(cls, origin, node, cluster_ids)
  -- pull up all neighbouring nodes from the given clusters
  local neighbours = {}

  local color = self:get_node_color(node)

  if cluster_ids and not is_table_empty(cluster_ids) then
    for dir6, vec3 in pairs(DIR6_TO_VEC3) do
      local npos = vector.add(origin, vec3)

      for cluster_id, _ in pairs(cluster_ids) do
        local cluster = cls:get_cluster(cluster_id)
        if cluster then
          local node_entry = cluster:get_node(npos)

          if node_entry then
            local other_color = self:get_node_color(node_entry.node)

            if self:is_compatible_colors(color, other_color) then
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
  end

  return neighbours
end

function ic:_handle_add_node(cls, generation_id, event, given_cluster_ids)
  local neighbours = self:find_compatible_neighbours(cls, event.pos, event.node, given_cluster_ids)

  local cluster
  if is_table_empty(neighbours) then
    -- need a new cluster for this node
    cluster = cls:create_cluster({ [self.m_cluster_group] = 1 })
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

  yatm.queue_refresh_infotext(event.pos, event.node)

  cls:add_node_to_cluster(cluster.id, event.pos, event.node, event.params.groups)

  cluster.assigns.generation_id = generation_id
end

function ic:_handle_update_node(cls, generation_id, event, given_cluster_ids)
  local cluster
  for cluster_id, _ in pairs(given_cluster_ids) do
    local ncluster = cls:get_cluster(cluster_id)
    if ncluster and ncluster.groups[self.m_cluster_group] then
      cluster = ncluster
    end
  end

  if cluster then
    cls:update_node_in_cluster(cluster.id, event.pos, event.node, event.params.groups)
  end
end

function ic:mark_accessible_dirs(pos, node, accessible_dirs)
  local color = self:get_node_color(node)

  for dir6, vec3 in pairs(DIR6_TO_VEC3) do
    local npos = vector.add(pos, vec3)
    local nnode = minetest.get_node_or_nil(npos)

    if nnode then
      local rating = minetest.get_item_group(nnode.name, self.m_node_group)
      if rating and rating > 0 then
        local other_color = self:get_node_color(nnode)

        if self:is_compatible_colors(color, other_color) then
          -- okay
        else
          --print("dir is inaccesible, not a compatible color", minetest.pos_to_string(npos), nnode.name, dump(color), dump(other_color))
          accessible_dirs[dir6] = false
        end
      else
        accessible_dirs[dir6] = false
      end
    else
      accessible_dirs[dir6] = false
    end
  end

  return accessible_dirs
end

function ic:scan_for_branches(origin, node)
  local all_nodes = {}
  local branches = {}
  local hash_node_position = minetest.hash_node_position
  local table_merge = yatm_core.table_merge
  local table_bury = yatm_core.table_bury

  local g_branch_id = 0
  for dir6, vec3 in pairs(DIR6_TO_VEC3) do
    g_branch_id = g_branch_id + 1
    local branch_id = g_branch_id
    local origin = vector.add(origin, vec3)
    local nodes = {}
    branches[branch_id] = nodes

    yatm.explore_nodes(origin, 0, function (pos, node, acc, accessible_dirs)
      local node_id = hash_node_position(pos)
      if nodes[node_id] then
        return false, acc
      end

      local nodedef = minetest.registered_nodes[node.name]
      if nodedef then
        if nodedef.groups[self.m_node_group] then
          if all_nodes[node_id] then
            local other_branch_id = all_nodes[node_id]
            local other_branches = branches[other_branch_id]

            if nodes ~= other_branches then
              local new_nodes = {}
              table_merge(nodes, other_branches)
              for node_id,_ in pairs(nodes) do
                all_nodes[node_id] = other_branch_id
                new_nodes[node_id] = other_branch_id
              end
              for node_id,_ in pairs(other_branches) do
                all_nodes[node_id] = other_branch_id
                new_nodes[node_id] = other_branch_id
              end
              branches[other_branch_id] = new_nodes
              branches[branch_id] = nil
              branch_id = other_branch_id
              nodes = new_nodes
            end
          else
            all_nodes[node_id] = branch_id
            nodes[node_id] = branch_id
          end

          self:mark_accessible_dirs(pos, node, accessible_dirs)

          return true, acc + 1
        else
          return false, acc
        end
      else
        return false, acc
      end
    end)
  end

  return branches
end

function ic:_handle_remove_node(cls, generation_id, event, _cluster_ids)
  -- TODO:
  local cluster_id =
    cls:reduce_node_clusters(event.pos, nil, function (cluster, acc)
      if cluster.groups[self.m_cluster_group] then
        return false, cluster.id
      else
        return true, acc
      end
    end)

  if cluster_id then
    cls:remove_node_from_cluster(cluster_id, event.pos, event.node)
  end

  local branches = self:scan_for_branches(event.pos, event.node)

  local affected_clusters = {}
  local branch_id_to_cluster_id = {}
  for branch_id, nodes in pairs(branches) do
    for node_id, _ in pairs(nodes) do
      local pos = minetest.get_position_from_hash(node_id)

      local cluster_id =
        cls:reduce_node_clusters(pos, nil, function (cluster, acc)
          if cluster.groups[self.m_cluster_group] then
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

  for branch_id, nodes in pairs(branches) do
    if not is_table_empty(nodes) then
      local cluster = cls:create_cluster({ [self.m_cluster_group] = 1 })

      for node_id, _ in pairs(nodes) do
        local pos = minetest.get_position_from_hash(node_id)
        local node = minetest.get_node(pos)

        cls:add_node_to_cluster(cluster.id, pos, node, self:get_node_groups(node))
        yatm.queue_refresh_infotext(pos, node)
      end
    end
  end
end

yatm_clusters.SimpleCluster = SimpleCluster
