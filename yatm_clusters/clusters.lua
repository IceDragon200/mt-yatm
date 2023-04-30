--
-- A Cluster is single network of nodes
--
local is_table_empty = assert(foundation.com.is_table_empty)
local table_length = assert(foundation.com.table_length)
local table_copy = assert(foundation.com.table_copy)
local Vector3 = assert(foundation.com.Vector3)
local List = assert(foundation.com.List)

local hash_pos = minetest.hash_node_position
-- @namespace yatm_clusters

-- @type ClusterNode: {
--   id: Integer,
--   pos: Vector3,
--   node: NodeRef,
--   groups: Table<String, Integer>,
--   assigns: Table,
-- }

--- @class Cluster
local Cluster = foundation.com.Class:extends("YATM.Cluster")
do
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
    --
    self.terminated = false
    self.terminate_reason = false
  end

  --- @spec #terminate(reason: String): void
  function ic:terminate(reason)
    -- print("Terminating Cluster cluster_id=" .. self.id .. " reason=" .. reason)
    self.terminate_reason = reason
    self.terminated = true
  end

  --- @spec #size(): Integer
  function ic:size()
    return table_length(self.m_nodes)
  end

  --- @spec #is_empty(): Boolean
  function ic:is_empty()
    return is_table_empty(self.m_nodes)
  end

  --- @spec #inspect(): String
  function ic:inspect()
    return dump({
      id = self.id,
      groups = self.groups,
      assigns = self.assigns,
      nodes = self.m_nodes,
      block_nodes = self.m_block_nodes,
      group_nodes = self.m_group_nodes,
      pinned = self.pinned,
    })
  end

  --- @spec #merge(Cluster): self
  function ic:merge(other_cluster)
    assert(other_cluster, "expected a cluster")

    for group_id, group_value in pairs(other_cluster.groups) do
      self.groups[group_id] = group_value
    end

    for node_id, node_entry in pairs(other_cluster.m_nodes) do
      assert(type(node_entry) == "table")
      self.m_nodes[node_id] = node_entry
    end

    for block_id, block_nodes in pairs(other_cluster.m_block_nodes) do
      if not self.m_block_nodes[block_id] then
        self.m_block_nodes[block_id] = {}
      end
      for node_id,value in pairs(block_nodes) do
        self.m_block_nodes[block_id][node_id] = value
      end
    end

    for group_id, group_nodes in pairs(other_cluster.m_group_nodes) do
      if not self.m_group_nodes[group_id] then
        self.m_group_nodes[group_id] = {}
      end
      for node_id,value in pairs(group_nodes) do
        self.m_group_nodes[group_id][node_id] = value
      end
    end

    for key, value in pairs(other_cluster.assigns) do
      self.assigns[key] = value
    end

    return self
  end

  --- @spec #move_nodes_from_cluster(Cluster, Table): String
  function ic:move_nodes_from_cluster(other_cluster, nodes_to_transfer)
    assert(other_cluster, "expected other cluster")
    local node_entry
    for node_id, _ in pairs(nodes_to_transfer) do
      node_entry = other_cluster.m_nodes[node_id]
      assert(type(node_entry) == "table", "expected node entry to be a table")
      self.m_nodes[node_id] = node_entry
      other_cluster.m_nodes[node_id] = nil
      self:_refresh_node_entry(node_entry)
    end
  end

  function ic:_refresh_node_entry(node_entry)
    for group_id, group_value in pairs(node_entry.groups) do
      if not self.m_group_nodes[group_id] then
        self.m_group_nodes[group_id] = {}
      end

      --[[
      print("clusters.cluster", "cluster_id=" .. self.id,
                                "node=" .. node_entry.node.name,
                                "pos=" .. minetest.pos_to_string(node_entry.pos),
                                "group=" .. group_id,
                                "adding to group")]]

      self.m_group_nodes[group_id][node_entry.id] = group_value
    end

    local block_id = yatm.clusters:mark_node_block(node_entry.pos, node_entry.node)
    node_entry.block_id = block_id

    if not self.m_block_nodes[block_id] then
      self.m_block_nodes[block_id] = {}
    end
    self.m_block_nodes[block_id][node_entry.id] = true
  end

  --- @spec #add_node(pos: Vector3, node: ClusterNode, groups: Table<String, Integer>): Boolean
  function ic:add_node(pos, node, groups)
    local node_id = hash_pos(pos)

    if self.m_nodes[node_id] then
      print(debug.traceback())
      local old_node = self.m_nodes[node_id]
      if old_node.node.name == node.name then
        minetest.log("warning", "duplicate node registration detected" ..
                              " cluster_id=" .. self.id ..
                              " node_id=" .. node_id ..
                              " pos=" .. minetest.pos_to_string(pos) ..
                              " name=" .. node.name)
        return false, "duplicate node registration"
      else
        minetest.log("warning", "dangerous node replacement" ..
                                " cluster_id=" .. self.id ..
                                " node_id=" .. node_id ..
                                " pos=" .. minetest.pos_to_string(pos) ..
                                " name=" .. node.name)
      end
    end

    local node_entry = {
      id = node_id,
      pos = Vector3.copy(pos),
      node = table_copy(node),
      groups = groups or {},
      assigns = {}
    }

    self.m_nodes[node_id] = node_entry
    self:_refresh_node_entry(node_entry)

    self:on_node_added(node_entry)
    return true
  end

  --- @spec #get_node(Vector3): ClusterNode
  function ic:get_node(pos)
    local node_id = hash_pos(pos)

    return self.m_nodes[node_id]
  end

  --- @spec #get_node_by_id(id: Integer): nil | ClusterNode
  function ic:get_node_by_id(node_id)
    return self.m_nodes[node_id]
  end

  --- @spec #get_node_group(pos: Vector3, group_name: String): Integer
  function ic:get_node_group(pos, group_name)
    local entry = self:get_node(pos)

    if entry then
      return entry.groups[group_name] or 0
    end
    return 0
  end

  --- @spec #update_node(
  ---   pos: Vector3,
  ---   node: ClusterNode,
  ---   groups: Table<String, Integer>
  --- ): (Boolean, error: String)
  function ic:update_node(pos, node, groups)
    local node_id = hash_pos(pos)
    local old_node_entry = self.m_nodes[node_id]

    if old_node_entry then
      local group_nodes
      for group_name,group_value in pairs(old_node_entry.groups) do
        group_nodes = self.m_group_nodes[group_name]
        if group_nodes then
          group_nodes[node_id] = nil
          if not next(group_nodes) then
            self.m_group_nodes[group_name] = nil
          end
        end
      end

      local node_entry = {
        id = node_id,
        pos = Vector3.copy(pos),
        node = table_copy(node),

        groups = groups or {},

        assigns = old_node_entry.assigns or {}
      }

      self.m_nodes[node_id] = node_entry
      self:_refresh_node_entry(node_entry)

      self:on_node_updated(node_entry, old_node_entry)

      return true
    else
      return false, "node not found"
    end
  end

  --- @spec #remove_node(pos: Vector3, node: ClusterNode, reason: String): (Boolean, error: String)
  function ic:remove_node(pos, node, reason)
    local node_id = hash_pos(pos)

    local node_entry = self.m_nodes[node_id]
    if node_entry then
      -- remove from groups
      local group_nodes
      for group_name,group_value in pairs(node_entry.groups) do
        group_nodes = self.m_group_nodes[group_name]
        if group_nodes then
          group_nodes[node_id] = nil
          if not next(group_nodes) then
            self.m_group_nodes[group_name] = nil
          end
        end
      end

      if node_entry.block_id then
        local nodes = self.m_block_nodes[node_entry.block_id]
        if nodes then
          nodes[node_id] = nil

          if is_table_empty(nodes) then
            self.m_block_nodes[node_entry.block_id] = nil
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

  --- @spec #on_node_added(node_entry: ClusterNode): void
  function ic:on_node_added(node_entry)
    --
  end

  --- @spec #on_node_updated(new_node_entry: ClusterNode, old_node_entry: ClusterNode): void
  function ic:on_node_updated(new_node_entry, old_node_entry)
    --
  end

  --- @spec #on_node_removed(node_entry: ClusterNode, reason: String): void
  function ic:on_node_removed(node_entry, reason)
    --
  end

  --- @spec #on_block_expired(block_id: String): void
  function ic:on_block_expired(block_id)
    if self.m_block_nodes[block_id] then
      local old_nodes = self.m_block_nodes[block_id]
      self.m_block_nodes[block_id] = nil

      local node_entry
      for node_id, _ in pairs(old_nodes) do
        node_entry = self.m_nodes[node_id]
        if node_entry then
          self:remove_node(node_entry.pos, node_entry.node, 'block_expired')
        end
      end
    end
  end

  ---
  --- @type ReducerFunction: function(node_entry: NodeEntry, acc: Any) =>
  ---         (continue_reduce: Boolean, acc: Any)
  ---

  --- @spec #reduce_nodes(acc: Table, reducer: ReducerFunction): Table
  function ic:reduce_nodes(acc, reducer)
    local continue_reduce = true
    for node_id, node_entry in pairs(self.m_nodes) do
      continue_reduce, acc = reducer(node_entry, acc)
      if not continue_reduce then
        break
      end
    end
    return acc
  end

  --- @spec #reduce_nodes_in_block(
  ---   block_id: String,
  ---   acc: Table,
  ---   reducer: ReducerFunction
  --- ): (acc: Any)
  function ic:reduce_nodes_in_block(block_id, acc, reducer)
    assert(type(block_id) == "number", "expected block_id to be a number")
    local continue_reduce = true
    local node_ids = self.m_block_nodes[block_id]
    if node_ids then
      local node_entry
      for node_id, _ in pairs(node_ids) do
        node_entry = self.m_nodes[node_id]
        if node_entry then
          continue_reduce, acc = reducer(node_entry, acc)
          if not continue_reduce then
            break
          end
        else
          minetest.log("error", "potential block corruption block_id=" .. block_id ..
            " missing node entry node_id=" .. node_id)
        end
      end
    end
    return acc
  end

  --- @spec #reduce_nodes_of_groups(groups: String[], acc: Any, ReducerFunction): (acc: Any)
  function ic:reduce_nodes_of_groups(groups, acc, reducer)
    if type(groups) == "string" then
      groups = {groups}
    end
    assert(type(groups) == "table", "expected groups to be table")

    local primary_group = groups[1]
    local groups_count = #groups
    local primary_list = self.m_group_nodes[primary_group]

    if primary_list then
      local continue_reduce = true
      local should_continue
      local member_list
      local node_entry

      for node_id,group_value in pairs(primary_list) do
        should_continue = true

        if groups_count > 1 then
          for _,group_name in ipairs(groups) do
            member_list = self.m_group_nodes[group_name]

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
          node_entry = self.m_nodes[node_id]
          continue_reduce, acc = reducer(node_entry, acc)
        end

        if not continue_reduce then
          break
        end
      end
    end
    return acc
  end

  ---
  --- Optimized version of reduce_nodes_of_groups, targets only a single group
  ---
  --- @spec #reduce_nodes_of_group(group: String, acc: Any, reducer: Function/2): Any
  function ic:reduce_nodes_of_group(group, acc, reducer)
    local primary_list = self.m_group_nodes[group]

    if primary_list then
      local continue_reduce = true
      local should_continue
      local node_entry

      for node_id,group_value in pairs(primary_list) do
        should_continue = true

        if should_continue then
          node_entry = self.m_nodes[node_id]
          continue_reduce, acc = reducer(node_entry, acc)
        end

        if not continue_reduce then
          break
        end
      end
    end
    return acc
  end

  ---
  --- @spec get_nodes_of_group(group_name: String): ClusterNode[]
  function ic:get_nodes_of_group(group_name)
    local member_list = self.m_group_nodes[group_name]
    local result = {}
    if member_list then
      local i = 0
      for node_id,_ in pairs(member_list) do
        i = i + 1
        result[i] = self.m_nodes[node_id]
      end
    end
    return result
  end

  --
  -- Counts all nodes present in the specified group of the cluster
  --
  -- @spec #count_nodes_of_group(group_name: String): Integer
  function ic:count_nodes_of_group(group_name)
    local member_list = self.m_group_nodes[group_name]
    if member_list then
      local count = 0

      for node_id,_ in pairs(member_list) do
        count = count + 1
      end

      return count
    end

    return 0
  end
end

--
-- Clusters represent a unified format and system for joining nodes together
-- to form 'networks'.
--
local MAP_BLOCK_SIZE3 = Vector3.new(16, 16, 16)

--- @class Clusters
local Clusters = foundation.com.Class:extends("YATM.Clusters")
do
  local ic = Clusters.instance_class

  -- @spec #initialize(): void
  function ic:initialize()
    self.m_counter = 0

    self.m_acc_dtime = 0

    -- Clusters
    self.m_cluster_id = 0
    -- Clusters (Cluster ID > Cluster)
    self.m_clusters = {}
    -- Clusters (Cluster ID > Cluster)
    self.m_dead_clusters = {}
    -- Cluster Groups (Group Name > {Cluster ID})
    self.m_group_clusters = {}
    -- Node ID > {Cluster ID}
    self.m_node_clusters = {}

    -- @member m_queued_node_events: List<Event>
    self.m_queued_node_events = List:new()

    -- A life-cycle system, this determines if a mapblock is still loaded
    -- by checking 1 of it's nodes for "ignore", if it receives an "ignore"
    -- the block is considered unloaded and all clusters will be notified
    self.m_active_blocks = {}

    self.m_observers = {}

    -- A list of systems that should execute against the clusters
    self.m_systems = {}

    self.m_node_event_handlers = {}

    self.m_next_tick_callbacks = List:new()
  end

  -- @spec #terminate(): void
  function ic:terminate()
    print("clusters", "terminating")
    self:_send_to_observers('terminate', nil)
    print("clusters", "terminated")
  end

  function ic:schedule_node_event(cluster_group, event_name, pos, node, params)
    assert(pos, "need a position")
    -- print(
    --   "clusters",
    --   "schedule_node_event",
    --   cluster_group,
    --   event_name,
    --   minetest.pos_to_string(pos),
    --   node.name
    -- )
    local node_id = minetest.hash_node_position(pos)
    local node_name = "N/A"
    if node then
      node_name = node.name
    end

    -- print(
    --   "pushing_node_event",
    --   "node_id:", node_id,
    --   "event_name:", event_name,
    --   "from_node:", node_name,
    --   "params: ", dump(params)
    -- )

    self.m_queued_node_events:push({
      cluster_group = cluster_group,
      event_name = event_name,
      pos = pos,
      node_id = node_id,
      node = node,
      params = params,
    })
  end

  --
  -- Node Blocks
  --
  function ic:mark_node_block(pos, node)
    assert(pos, "expected a node position")
    assert(node, "expected a node")
    local block_pos = Vector3.idiv({}, pos, MAP_BLOCK_SIZE3)
    local block_hash = minetest.hash_node_position(block_pos)

    --self:log("info", "clusters mark_node_block/2", minetest.pos_to_string(pos), dump(node.name))

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

  -- @spec #create_cluster(groups: Table): Cluster
  function ic:create_cluster(groups)
    groups = groups or {}
    self.m_cluster_id = self.m_cluster_id + 1
    local cluster_id = self.m_cluster_id

    local cluster = Cluster:new(cluster_id, groups)
    self.m_clusters[cluster_id] = cluster

    -- print("clusters", "create_cluster", cluster.id)

    for group_name,group_value in pairs(cluster.groups) do
      if not self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name] = {}
      end
      self.m_group_clusters[group_name][cluster_id] = group_value
    end

    return cluster
  end

  function ic:merge_clusters(cluster_ids)
    -- print("clusters", "merge_clusters", table.concat(cluster_ids, ", "))

    local result_cluster = self:create_cluster()
    local cluster

    for _,cluster_id in ipairs(cluster_ids) do
      cluster = self:remove_cluster_by_id(cluster_id)

      if cluster then
        result_cluster:merge(cluster)
      end
    end

    for group_name, group_value in pairs(result_cluster.groups) do
      if not self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name] = {}
      end

      self.m_group_clusters[group_name][result_cluster.id] = group_value
    end

    result_cluster:reduce_nodes(0, function (node_entry, acc)
      self:_add_node_to_cluster_groups(node_entry.pos, node_entry.node, result_cluster.id)
      return true, acc + 1
    end)

    -- print(
    --   "clusters",
    --   "merged_clusters",
    --   table.concat(cluster_ids, ", "), " into cluster_id=" .. result_cluster.id
    -- )

    return result_cluster
  end

  function ic:get_cluster(cluster_id)
    return self.m_clusters[cluster_id]
  end

  function ic:update_cluster_groups(cluster_id, groups)
    local cluster = self.m_clusters[cluster_id]
    local old_groups = cluster.groups
    cluster.groups = groups

    for group_name, _group_value in pairs(old_groups) do
      if self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name][cluster_id] = nil
      end

      if is_table_empty(self.m_group_clusters[group_name]) then
        self.m_group_clusters[group_name] = nil
      end
    end

    for group_name,group_value in pairs(cluster.groups) do
      if not self.m_group_clusters[group_name] then
        self.m_group_clusters[group_name] = {}
      end

      self.m_group_clusters[group_name][cluster_id] = group_value
    end
    return self
  end

  -- @spec #remove_cluster_by_id(cluster_id: Integer): Cluster
  function ic:remove_cluster_by_id(cluster_id)
    -- print("clusters", "remove_cluster", cluster_id)

    local cluster = self.m_clusters[cluster_id]
    if cluster then
      self:_cleanup_cluster(cluster)
      self.m_clusters[cluster_id] = nil
    end

    return cluster
  end

  -- @spec
  function ic:_cleanup_cluster(cluster)
    local group_clusters
    for group_name, _group_value in pairs(cluster.groups) do
      group_clusters = self.m_group_clusters[group_name]
      if group_clusters then
        group_clusters[cluster.id] = nil
        if is_table_empty(group_clusters) then
          self.m_group_clusters[group_name] = nil
        end
      end
    end

    cluster:reduce_nodes(0, function (node_entry, acc)
      self:_remove_node_from_cluster_groups(
        cluster.id,
        node_entry.pos,
        node_entry.node
      )
      return true, acc + 1
    end)
  end

  function ic:destroy_cluster(cluster_id, reason)
    -- print("clusters", "destroy_cluster", cluster_id)

    local cluster = self:remove_cluster_by_id(cluster_id)
    if cluster then
      cluster:terminate(reason or "destroy")
      self:_on_cluster_destroyed(cluster)
    end

    return cluster
  end

  function ic:reduce_clusters_of_group(group_name, acc, callback)
    local cluster_ids = self.m_group_clusters[group_name]
    local should_continue
    local cluster

    if cluster_ids then
      for cluster_id, _ in pairs(cluster_ids) do
        cluster = self.m_clusters[cluster_id]
        if cluster then
          should_continue, acc = callback(cluster, acc)
          if not should_continue then
            break
          end
        end
      end
    end

    return acc
  end

  function ic:_on_cluster_destroyed(cluster)
    self:_send_to_observers("on_cluster_destroyed", cluster)
  end

  --
  -- Node Management
  --
  function ic:move_nodes_from_cluster(nodes, origin_cluster, target_cluster)
    for node_id, _ in pairs(nodes) do
      self:_remove_node_id_from_cluster_groups(origin_cluster.id, node_id)
    end
    target_cluster:move_nodes_from_cluster(origin_cluster, nodes)
    for node_id, _ in pairs(nodes) do
      self:_add_node_id_to_cluster_groups(target_cluster.id, node_id)
    end
  end

  function ic:add_node_to_cluster(cluster_id, pos, node, groups)
    local cluster = self.m_clusters[cluster_id]
    cluster:add_node(pos, node, groups)
    self:_add_node_to_cluster_groups(pos, node, cluster_id)
  end

  function ic:_add_node_to_cluster_groups(pos, node, cluster_id)
    local node_id = minetest.hash_node_position(pos)
    self:_add_node_id_to_cluster_groups(node_id, cluster_id)
  end

  function ic:_add_node_id_to_cluster_groups(node_id, cluster_id)
    if not self.m_node_clusters[node_id] then
      self.m_node_clusters[node_id] = {}
    end
    self.m_node_clusters[node_id][cluster_id] = true
  end

  -- @spec update_node_in_cluster(
  --   cluster_id: ID,
  --   pos: Vector3,
  --   node: NodeRef,
  --   groups: Table
  -- ): (updated: Boolean, error: String)
  function ic:update_node_in_cluster(cluster_id, pos, node, groups)
    local cluster = self.m_clusters[cluster_id]
    return cluster:update_node(pos, node, groups)
  end

  function ic:remove_node_from_cluster(cluster_id, pos, node)
    local cluster = self.m_clusters[cluster_id]
    cluster:remove_node(pos, node)

    self:_remove_node_from_cluster_groups(cluster_id, pos, node)
  end

  function ic:_remove_node_from_cluster_groups(cluster_id, pos, node)
    local node_id = minetest.hash_node_position(pos)
    self:_remove_node_id_from_cluster_groups(cluster_id, node_id)
  end

  function ic:_remove_node_id_from_cluster_groups(cluster_id, node_id)
    if self.m_node_clusters[node_id] then
      self.m_node_clusters[node_id][cluster_id] = nil

      if is_table_empty(self.m_node_clusters[node_id]) then
        self.m_node_clusters[node_id] = nil
      end
    end
  end

  function ic:get_cluster_by_pos_and_group(pos, group_name)
    local node_id = minetest.hash_node_position(pos)

    local cluster_ids = self.m_node_clusters[node_id]
    if cluster_ids then
      local cluster
      for cluster_id, _ in pairs(cluster_ids) do
        cluster = self:get_cluster(cluster_id)

        if cluster then
          if cluster.groups[group_name] then
            return cluster
          end
        end
      end
    end

    return nil
  end

  --- @spec #reduce_node_clusters_by_id(node_id: Integer, acc: Any, reducer: Function/2): (acc: Any)
  function ic:reduce_node_clusters_by_id(node_id, acc, reducer)
    local node_clusters = self.m_node_clusters[node_id]
    if node_clusters then
      local continue_reduce = true
      local cluster
      for cluster_id, _ in pairs(node_clusters) do
        cluster = self:get_cluster(cluster_id)

        if cluster then
          continue_reduce, acc = reducer(cluster, acc)
        end

        if not continue_reduce then
          break
        end
      end
    end

    return acc
  end

  --- @spec #reduce_node_clusters(pos: Vector3, acc: Any, reducer: Function/2): (acc: Any)
  function ic:reduce_node_clusters(pos, acc, reducer)
    assert(pos, "expected a position")
    local node_id = minetest.hash_node_position(pos)
    return self:reduce_node_clusters_by_id(node_id, acc, reducer)
  end

  --
  -- System Management
  --

  --- @spec register_system(cluster_group: String, system_id: String, update: Function/1): void
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

  -- default = 1 / 4 -- (every 250ms)
  -- local STEP_INTERVAL = 1 / 60 -- every 16ms
  local STEP_INTERVAL = 1 / 20 -- every 50ms
  --local STEP_INTERVAL = 1 / 10 -- every 100ms

  --
  -- Update
  --

  -- @spec #update(dtime: Float, trace: Trace): void
  function ic:update(dtime, trace)
    self.m_counter = self.m_counter + 1

    --
    -- Resolve any active block events, or expire dead blocks
    --
    self:_update_active_blocks(dtime, trace)

    --
    -- Resolve any queued node events
    --
    self:_resolve_node_events(dtime, trace)

    self.m_acc_dtime = self.m_acc_dtime + dtime

    if self.m_acc_dtime > STEP_INTERVAL then
      self.m_acc_dtime = self.m_acc_dtime - STEP_INTERVAL

      --
      -- Run any other cluster updates
      --
      self:_update_clusters(STEP_INTERVAL, trace)

      --
      -- Run update logic against clusters with systems
      --
      self:_update_systems(STEP_INTERVAL, trace)

      self:_handle_next_tick_calls(STEP_INTERVAL)
    end
  end

  function ic:_update_active_blocks(dtime, trace)
    local has_expired_blocks = false

    local span

    if trace then
      span = trace:span_start("_update_active_blocks")
    end

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
          -- print("clusters", "block expired", entry.id, minetest.pos_to_string(entry.pos))
          -- block expiration hooks
          self:_send_to_observers("pre_block_expired", entry)

          -- Expire the block
          self:_on_block_expired(entry.id)
        else
          self.m_active_blocks[block_hash] = entry
        end
      end
    end

    if span then
      span:span_end()
    end
  end

  function ic:register_node_event_handler(cluster_group, callback_name, callback)
    assert(type(cluster_group) == "string", "expected a cluster group name")
    assert(type(callback_name) == "string", "expected a callback name")
    assert(type(callback) == "function", "expected callback to be a function")

    -- print(
    --   "clusters",
    --   "registering node_event_handler cluster_group=" .. cluster_group,
    --   "callback_name=" .. callback_name
    -- )

    if not self.m_node_event_handlers[cluster_group] then
      self.m_node_event_handlers[cluster_group] = {}
    end
    local group_handlers = self.m_node_event_handlers[cluster_group]
    group_handlers[callback_name] = callback

    return self
  end

  function ic:_resolve_node_events(dtime, trace)
    local span

    if trace then
      span = trace:span_start("_resolve_node_events")
    end

    if not self.m_queued_node_events:is_empty() then
      local node_event_queue = self.m_queued_node_events:data()
      local len = self.m_queued_node_events:size()
      self.m_queued_node_events:clear()

      local handlers
      local cluster_ids
      local handler_trace
      local event

      local cluster_group
      for index = 1,len do
        event = node_event_queue[index]
        cluster_group = event.cluster_group

        handlers = self.m_node_event_handlers[cluster_group]

        -- print("processing event", dump(event), "handlers", dump(handlers))

        if handlers then
          for callback_name, callback in pairs(handlers) do
            if span then
              handler_trace = span:span_start(callback_name)
            end
            cluster_ids = self.m_group_clusters[cluster_group]

            -- print(callback_name, callback, dump(event))

            callback(self, self.m_counter, event, cluster_ids, handler_trace)

            if handler_trace then
              handler_trace:span_end()
            end
          end
        end
      end
    end

    if span then
      span:span_end()
    end
  end

  function ic:_update_systems(dtime, mod_trace)
    local cluster_ids
    local cluster
    local func_trace
    local sys_trace
    local cls_trace

    if mod_trace then
      func_trace = mod_trace:span_start("_update_systems")
    end

    for system_id, system in pairs(self.m_systems) do
      if func_trace then
        sys_trace = func_trace:span_start(system_id)
      end

      cluster_ids = self.m_group_clusters[system.cluster_group]
      if cluster_ids then
        for cluster_id, _ in pairs(cluster_ids) do
          cluster = self.m_clusters[cluster_id]
          if cluster then
            if sys_trace then
              cls_trace = sys_trace:span_start(cluster_id)
            end
            system.update(self, cluster, dtime, cls_trace)
            if cls_trace then
              cls_trace:span_end()
            end
          else
            print("clusters", "WARN", "missing cluster cluster_id=" .. cluster_id)
          end
        end
      end

      if sys_trace then
        sys_trace:span_end()
      end
    end

    if func_trace then
      func_trace:span_end()
    end
  end

  function ic:_update_clusters(dtime, trace)
    local span

    if trace then
      span = trace:span_start("_update_clusters")
    end

    for cluster_id, cluster in pairs(self.m_clusters) do
      if cluster:is_empty() then
        if not cluster.pinned then
          self.m_dead_clusters[cluster_id] = cluster
          break
        end
      end
    end

    if next(self.m_dead_clusters) then
      for cluster_id, cluster in pairs(self.m_dead_clusters) do
        self:destroy_cluster(cluster_id, 'empty')
      end

      self.m_dead_clusters = {}
    end

    if span then
      span:span_end()
    end
  end

  ---
  --- Invokes all recently registered next_tick callbacks
  --- The callbacks are cleared afterwards
  ---
  --- @spec _handle_next_tick_calls(dtime: Float): void
  function ic:_handle_next_tick_calls(dtime)
    if not self.m_next_tick_callbacks:is_empty() then
      local data = self.m_next_tick_callbacks:data()
      local size = self.m_next_tick_callbacks:size()

      -- allows the callbacks to register another next_tick
      self.m_next_tick_callbacks:clear()
      local item
      for i = 1,size do
        item = data[i]
        item(self, dtime)
      end
    end
  end

  --
  -- Block Expiration hook
  --
  function ic:_on_block_expired(block_id)
    for cluster_id,cluster in pairs(self.m_clusters) do
      cluster:on_block_expired(block_id)
    end
    self:_send_to_observers("on_block_expired", block_id)
  end

  --
  -- Observation Hooks
  --
  function ic:observe(group, id, callback)
    assert(group, "requires a group")
    assert(id, "requires a id")
    assert(callback, "requires a callback")
    -- print("registering callback group:" .. group .. " id:" .. id .. " callback:" .. dump(callback))
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

  --
  -- Next Tick callbacks
  --
  function ic:on_next_tick(callback)
    assert(type(callback) == "function", "expected function as callback")

    self.m_next_tick_callbacks:push(callback)
  end
end

yatm_clusters.Clusters = Clusters
yatm_clusters.clusters = Clusters:new()
