--
-- A Cluster is single network of nodes
--
local hash_pos = minetest.hash_node_position

local Cluster = yatm_core.Class:extends("YATM.Cluster")
local ic = Cluster.instance_class

function ic:initialize(id)
  self.id = id
  self.m_nodes = {}
  self.m_groups = {}
end

function ic:add_node(pos, node, groups)
  local node_id = hash_pos(pos)

  if self.m_nodes[node_id] then
    return false, "duplicate node registration"
  else
    self.m_nodes[node_id] = {
      id = node_id,
      pos = pos,
      node = node,
      groups = groups or {}
    }

    local node_entry = self.m_nodes[node_id]
    for group_name,group_value in pairs(node_entry.groups) do
      if not self.m_groups[group_name] then
        self.m_groups[group_name] = {}
      end
      self.m_groups[group_name][node_id] = group_value
    end
    self:on_node_added(node_entry)
    return true
  end
end

function ic:update_node(pos, node, groups)
  local node_id = hash_pos(pos)

  local old_node_entry = self.m_nodes[node_id]

  if old_node_entry then
    for group_name,group_value in pairs(old_node_entry.groups) do
      self.m_groups[group_name][node_id] = nil
    end

    self.m_nodes[node_id] = {
      id = node_id,
      pos = pos,
      node = node,
      groups = groups or {}
    }

    local node_entry = self.m_nodes[node_id]

    for group_name,group_value in pairs(node_entry.groups) do
      if not self.m_groups[group_name] then
        self.m_groups[group_name] = {}
      end
      self.m_groups[group_name][node_id] = group_value
    end
    self:on_node_updated(node_entry, old_node_entry)
    return true
  else
    return false, "node not found"
  end
end

function ic:remove_node(pos, node)
  local node_id = hash_pos(pos)

  local node_entry = self.m_nodes[node_id]
  if node_entry then
    -- remove from groups
    for group_name,group_value in pairs(node_entry.groups) do
      self.m_groups[group_name][node_id] = nil
    end

    self.m_nodes[node_id] = nil
    self:on_node_removed(node_entry)
    return true
  else
    return false, "node not found"
  end
end

function ic:on_node_added(node_entry)
  --
end

function ic:on_node_updated(new_node_entry, old_node_entry)
  --
end

function ic:on_node_removed(node_entry)
  --
end

function ic:reduce_nodes_of_groups(groups, acc, reducer)
  local primary_group = groups[1]
  local groups_count = #groups
  local primary_list = self.m_groups[primary_group]
  if primary_list then
    for node_id,group_value in pairs(primary_list) do
      local should_continue = true
      if #groups_count > 1 then
        for _,group_name in ipairs(groups) do
          local member_list = self.m_groups[group_name]
          if member_list then
            if not member_list[node_id] then
              should_continue = false
              break
            end
          else
            should_continue = false
            break
          end
        end
      end

      if should_continue then
        local node_entry = self.m_nodes[node_id]
        acc = reducer(node_entry, acc)
      end
    end
  end
  return acc
end

--
-- Cluster Discovery
--
local is_empty = yatm_core.is_table_empty
local vector4 = yatm_core.vector4
local DIR6_TO_VEC3 = yatm_core.DIR6_TO_VEC3
local invert_dir = yatm_core.invert_dir

function yatm_core.explore_nodes(origin, acc, reducer)
  local seen = {}
  local to_visit = {origin}

  while not is_empty(to_visit) do
    local new_to_visit = {}
    local n = 0
    for _,pos4 in ipairs(to_visit) do
      local hash = hash_pos(pos4)
      if not seen[hash] then
        seen[hash] = true
        local node = minetest.get_node(pos4)

        local accessible_dirs = {}
        local explore_neighbours
        for dir,_ in pairs(DIR6_TO_VEC3) do
          accessible_dirs[dir] = true
        end

        explore_neighbours, acc = reducer(pos, node, acc, accessible_dirs)

        if explore_neighbours then
          for dir,flag in pairs(accessible_dirs) do
            if flag and pos4.w ~= dir then
              local dirv3 = DIR6_TO_VEC3[dir]
              n = n + 1
              local npos4 = vector4.add({}, pos4, vec3)
              npos4.w = invert_dir(dir)
              new_to_visit[n] = npos4
            end
          end
        end
      end
    end
    to_visit = new_to_visit
  end
  return acc
end

--
-- Clusters represent a unified format and system for joining nodes together
-- to form 'networks'.
--
local Clusters = yatm_core.Class:extends("YATM.Clusters")
local ic = Clusters.instance_class

function ic:initialize()
  self.m_cluster_id = 0
  self.m_clusters = {}
  self.m_groups = {}
  self.m_nodes = {}
end

function ic:create_cluster()
  self.m_cluster_id = self.m_cluster_id + 1
  self.m_clusters[self.m_cluster_id] = Cluster:new(self.m_cluster_id)
  return self.m_clusters[self.m_cluster_id]
end

function ic:destroy_cluster(id)
  self.m_clusters[id] = nil
  return self
end

yatm_core.clusters = Clusters:new()
