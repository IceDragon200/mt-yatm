--
-- A Cluster is single network of nodes
--
local is_table_empty = yatm_core.is_table_empty
local vector3 = yatm_core.vector3

local hash_pos = minetest.hash_node_position

local Cluster = yatm_core.Class:extends("YATM.Cluster")
local ic = Cluster.instance_class

function ic:initialize(id, groups)
  self.id = id
  self.groups = groups
  self.assigns = {}
  self.m_nodes = {}
  self.m_block_nodes = {}
  self.m_group_nodes = {}
  -- Pinned clusters cannot be garbage collected
  self.pinned = false
end

function ic:terminate(reason)
  print("Terminating Cluster cluster_id=" .. self.id .. " reason=" .. reason)
end

function ic:is_empty()
  return is_table_empty(self.m_nodes)
end

function ic:merge(other_cluster)
  for group_id, group_value in pairs(other_cluster.groups) do
    self.groups[group_id] = group_value
  end

  for node_id, node_entry in pairs(other_cluster.m_nodes) do
    self.m_nodes[node_id] = node_entry
  end

  for block_id, block_nodes in pairs(other_cluster.m_block_nodes) do
    self.m_block_nodes[block_id] = block_nodes
  end

  for group_id, group_nodes in pairs(other_cluster.m_group_nodes) do
    self.m_group_nodes[group_id] = group_nodes
  end

  for key, value in pairs(other_cluster.assigns) do
    self.assigns[key] = value
  end

  return self
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
      groups = groups or {},
      assigns = {}
    }

    local node_entry = self.m_nodes[node_id]
    for group_name,group_value in pairs(node_entry.groups) do
      if not self.m_group_nodes[group_name] then
        self.m_group_nodes[group_name] = {}
      end

      self.m_group_nodes[group_name][node_id] = group_value
    end

    local block_id = yatm.clusters.mark_node_block(node_entry.pos)
    node_entry.block_id = block_id

    if not self.m_block_nodes[block_id] then
      self.m_block_nodes[block_id] = {}
    end
    self.m_block_nodes[block_id][node_id] = true

    self:on_node_added(node_entry)
    return true
  end
end

function ic:get_node(pos)
  local node_id = hash_pos(pos)

  return self.m_nodes[node_id]
end

function ic:update_node(pos, node, groups)
  local node_id = hash_pos(pos)
  local old_node_entry = self.m_nodes[node_id]

  if old_node_entry then
    for group_name,group_value in pairs(old_node_entry.groups) do
      if self.m_group_nodes[group_name] then
        self.m_group_nodes[group_name][node_id] = nil
      end

      if self.m_group_nodes[group_name] then
        self.m_group_nodes[group_name] = nil
      end
    end

    self.m_nodes[node_id] = {
      id = node_id,
      pos = pos,
      node = node,

      groups = groups or {},

      assigns = old_node_entry.assigns
    }

    local node_entry = self.m_nodes[node_id]

    for group_name,group_value in pairs(node_entry.groups) do
      if not self.m_group_nodes[group_name] then
        self.m_group_nodes[group_name] = {}
      end

      self.m_group_nodes[group_name][node_id] = group_value
    end

    local block_id = yatm.clusters.mark_node_block(node_entry.pos)
    node_entry.block_id = block_id

    if not self.m_block_nodes[block_id] then
      self.m_block_nodes[block_id] = {}
    end
    self.m_block_nodes[block_id][node_id] = true

    self:on_node_updated(node_entry, old_node_entry)

    return true
  else
    return false, "node not found"
  end
end

function ic:remove_node(pos, node, reason)
  local node_id = hash_pos(pos)

  local node_entry = self.m_nodes[node_id]
  if node_entry then
    -- remove from groups
    for group_name,group_value in pairs(node_entry.groups) do
      if self.m_group_nodes[group_name] then
        self.m_group_nodes[group_name][node_id] = nil
      end

      if is_table_empty(self.m_group_nodes[group_name]) then
        self.m_group_nodes[group_name] = nil
      end
    end

    if node_entry.block_id then
      local nodes = self.m_block_nodes[block_id]
      if nodes then
        nodes[node_id] = nil

        if is_table_empty(nodes) then
          self.m_block_nodes[block_id] = nil
        end
      end
    end

    self.m_nodes[node_id] = nil

    self:on_node_removed(node_entry, reason)

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

function ic:on_node_removed(node_entry, reason)
  --
end

function ic:on_block_expired(block_id)
  if self.m_block_nodes[block_id] then
    local old_nodes = self.m_block_nodes[block_id]
    self.m_block_nodes[block_id] = nil

    for node_id, _ in pairs(old_nodes) do
      local node_entry = self.m_nodes[node_id]
      if node_entry then
        self:remove_node(node_entry.pos, node_entry.node, 'block_expired')
      end
    end
  end
end

function ic:reduce_nodes_of_groups(groups, acc, reducer)
  local primary_group = groups[1]
  local groups_count = #groups
  local primary_list = self.m_group_nodes[primary_group]

  if primary_list then
    for node_id,group_value in pairs(primary_list) do
      local should_continue = true

      if #groups_count > 1 then
        for _,group_name in ipairs(groups) do
          local member_list = self.m_group_nodes[group_name]

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
-- Clusters represent a unified format and system for joining nodes together
-- to form 'networks'.
--
local MAP_BLOCK_SIZE3 = vector3.new(16, 16, 16)

local Clusters = yatm_core.Class:extends("YATM.Clusters")
local ic = Clusters.instance_class

function ic:initialize()
  self.m_counter = 0

  -- Clusters
  self.m_cluster_id = 0
  -- Clusters (Cluster ID > Cluster)
  self.m_clusters = {}
  -- Cluster Groups (Group Name > {Cluster ID})
  self.m_group_clusters = {}
  -- Node ID > Cluster ID
  self.m_node_clusters = {}

  -- Node ID > Events
  self.m_queued_node_events = {}

  -- A life-cycle system, this determines if a mapblock is still loaded
  -- by checking 1 of it's nodes for "ignore", if it receives an "ignore"
  -- the block is considered unloaded and all clusters will be notified
  self.m_active_blocks = {}

  self.m_observers = {}

  -- A list of systems that should execute against the clusters
  self.m_systems = {}

  self.m_node_event_handlers = {}
end

function ic:terminate()
  print("clusters", "terminate")
  self:_send_to_observers('terminate', nil)
end

function ic:schedule_node_event(cluster_group, event_name, pos, node, params)
  local node_id = minetest.hash_node_position(pos)
  if not self.m_queued_node_events[node_id] then
    self.m_queued_node_events[node_id] = {}
  end
  table.insert(self.m_queued_node_events[node_id],
                {
                  cluster_group = cluster_group,
                  event_name = event_name,
                  pos = pos,
                  node = node,
                  params = params,
                })
end

--
-- Node Blocks
--
function ic:mark_node_block(pos)
  assert(pos, "expected a node position")
  local block_pos = vector3.idiv({}, pos, MAP_BLOCK_SIZE3)
  local block_hash = minetest.hash_node_position(block_pos)

  print("clusters", "mark_node_block", minetest.pos_to_string(pos))
  -- mark the block as still active
  self.m_active_blocks[block_hash] = {
    id = block_hash,
    pos = pos,
    mapblock_pos = block_pos,
    expired = false,
    counter = self.m_counter
  }
  return block_hash
end

--
-- Cluster Management
--
function ic:create_cluster(groups)
  groups = groups or {}
  self.m_cluster_id = self.m_cluster_id + 1
  local cluster_id = self.m_cluster_id
  self.m_clusters[cluster_id] = Cluster:new(cluster_id, groups)

  print("clusters", "create_cluster", cluster_id)

  for group_name,group_value in pairs(groups) do
    if not self.m_group_clusters[group_name] then
      self.m_group_clusters[group_name] = {}
    end

    self.m_group_clusters[group_name][cluster_id] = group_value
  end

  return self.m_clusters[cluster_id]
end

function ic:merge_clusters(cluster_ids)
  local result_cluster = self:create_cluster()

  for _,cluster_id in ipairs(cluster_ids) do
    local cluster = self:remove_cluster(cluster_id)

    result_cluster:merge(cluster)
  end

  for group_name,group_value in pairs(result_cluster.groups) do
    if not self.m_group_clusters[group_name] then
      self.m_group_clusters[group_name] = {}
    end

    self.m_group_clusters[group_name][result_cluster.id] = group_value
  end

  return result_cluster
end

function ic:get_cluster(cluster_id)
  return self.m_clusters[cluster_id]
end

function ic:update_cluster(cluster_id, groups)
  local cluster = self.m_clusters[cluster_id]
  if cluster then
    for group_name, _group_value in pairs(cluster.groups) do
      if self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name][cluster_id] = nil
      end

      if is_table_empty(self.m_group_clusters[group_name]) then
        self.m_group_clusters[group_name] = nil
      end
    end

    for group_name,group_value in pairs(groups) do
      if not self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name] = {}
      end

      self.m_group_clusters[group_name][cluster_id] = group_value
    end
  end
  return self
end

function ic:remove_cluster(id)
  print("clusters", "destroy_cluster", id)

  local cluster = self.m_clusters[cluster_id]
  if cluster then
    for group_name, _group_value in pairs(cluster.groups) do
      if self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name][cluster_id] = nil
      end

      if is_table_empty(self.m_group_clusters[group_name]) then
        self.m_group_clusters[group_name] = nil
      end
    end
  end

  self.m_clusters[id] = nil
  return cluster
end

function ic:destroy_cluster(id)
  print("clusters", "destroy_cluster", id)

  local cluster = self:remove_cluster(cluster_id)
  if cluster then
    cluster:terminate('destroy')
    self:_on_cluster_destroyed(cluster)
  end
  return self
end

function ic:_on_cluster_destroyed(cluster)
  self:_send_to_observers("on_cluster_destroyed", cluster)
end

--
-- System Management
--
function ic:register_system(cluster_group, system_id, update)
  if self.m_systems[system_id] then
    error("a system system_id=" .. system_id .. " is already registered")
  else
    self.m_systems[system_id] = {
      cluster_group = cluster_group,
      update = update
    }
  end
end

--
-- Update
--
function ic:update(dtime)
  self.m_counter = self.m_counter + 1

  --
  -- Resolve any active block events, or expire dead blocks
  --
  self:_update_active_blocks()

  --
  -- Resolve any queued node events
  --
  self:_resolve_node_events()

  --
  -- Run update logic against clusters with systems
  --
  self:_update_systems()

  --
  -- Run any other cluster updates
  --
  self:_update_clusters()
end

function ic:_update_active_blocks()
  local has_expired_blocks = false

  for block_hash,entry in pairs(self.m_active_blocks) do
    if (self.m_counter - entry.counter) > 3 then
      if minetest.get_node_or_nil(entry.pos) then
        entry.counter = self.m_counter
      else
        entry.expired = true
        has_expired_blocks = true
      end
    end
  end

  if has_expired_blocks then
    local old_blocks = self.m_active_blocks
    self.m_active_blocks = {}
    for block_hash,entry in pairs(old_blocks) do
      if entry.expired then
        print("clusters", "block expired", entry.id, minetest.pos_to_string(entry.pos))
        self:_on_block_expired(entry.id)
      else
        self.m_active_blocks[block_hash] = entry
      end
    end
  end
end

function ic:register_node_event_handler(cluster_group, handler)
  print("clusters", "registering node_event_handler cluster_group=" .. cluster_group)
  self.m_node_event_handlers[cluster_group] = handler
end

function ic:_resolve_node_events()
  if not is_table_empty(self.m_queued_node_events) then
    local old_events = self.m_queued_node_events
    self.m_queued_node_events = {}
    for node_id,events in pairs(old_events) do
      for _,event in ipairs(events) do
        local handler = self.m_node_event_handlers[event.cluster_group]

        if handler then
          local clusters = self.m_group_clusters[event.cluster_group]

          handle(self, self.m_counter, event, clusters)
        end
      end
    end
  end
end

function ic:_update_systems()
  for system_id, system in pairs(self.m_systems) do
    local cluster_ids = self.m_group_clusters[system.cluster_group]
    if cluster_ids then
      for cluster_id, _ in pairs(cluster_ids) do
        local cluster = self.m_clusters[cluster_id]
        system.update(self, cluster)
      end
    end
  end
end

function ic:_update_clusters()
  local contains_empty_clusters = false
  for cluster_id, cluster in pairs(self.m_clusters) do
    if cluster:is_empty() then
      if not cluster.pinned then
        contains_empty_clusters = true
        break
      end
    end
  end

  if contains_empty_clusters then
    local old_clusters = self.m_clusters
    self.m_clusters = {}
    for cluster_id, cluster in pairs(old_clusters) do
      if cluster.pinned or not cluster:is_empty() then
        self.m_clusters[cluster_id] = cluster
      else
        cluster:terminate('empty')
      end
    end
  end
end

--
-- Block Expiration hook
--
function ic:_on_block_expired(entry)
  for cluster_id,cluster in pairs(self.m_clusters) do
    cluster:on_block_expired(entry)
  end
  self:_send_to_observers("on_block_expired", entry)
end

--
-- Observation Hooks
--
function ic:observe(group, id, callback)
  assert(group, "requires a group")
  assert(id, "requires a id")
  assert(callback, "requires a callback")
  print("registering callback group:" .. group .. " id:" .. id .. " callback:" .. dump(callback))
  if not self.m_observers[group] then
    self.m_observers[group] = {}
  end
  self.m_observers[group][id] = callback
end

function ic:disregard(group, id)
  if self.m_observers[group] then
    self.m_observers[group][id] = nil
  end
end

function ic:_send_to_observers(group, message)
  local observers = self.m_observers[group]
  if observers then
    for observer_id,observer_callback in pairs(observers) do
      observer_callback(message, group, observer_id)
    end
  end
end

yatm_core.clusters = Clusters:new()
