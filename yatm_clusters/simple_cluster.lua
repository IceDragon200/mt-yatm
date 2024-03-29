--
-- A Simple cluster is a blob of nodes that interconnect just by being beside each other.
-- It's the most basic form of cluster and normally used for things like thermal, energy and device,
-- clusters.
--
local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local table_merge = assert(foundation.com.table_merge)
local copy_node = assert(foundation.com.copy_node)
local node_to_string = assert(foundation.com.node_to_string)
local DIR6_TO_VEC3 = assert(foundation.com.Directions.DIR6_TO_VEC3)
local clusters = assert(yatm.clusters)
local list = assert(foundation.com.List)

local SimpleCluster = foundation.com.Class:extends("SimpleCluster")
do
  local ic = SimpleCluster.instance_class

  ---
  --- Options:
  --- * `cluster_group` - the name of the group this simple cluster will register as in the clusters
  ---                     system
  --- * `node_group` - the group the node MUST be apart of to be successfully registered in the
  ---                  cluster
  --- * `log_group` - a prefix used when logging information from the cluster
  ---
  --- @spec #initialize(options: Table): void
  function ic:initialize(options)
    if type(options) ~= "table" then
      error("expected options to be a table (got " .. type(options) .. ")")
    end
    self.m_cluster_group = assert(options.cluster_group)
    self.m_cluster_symbol_id = foundation.com.Symbols:symbol_to_id(self.m_cluster_group)
    self.m_node_group = assert(options.node_group)

    self.m_enable_logs = false
    self.m_log_group = assert(options.log_group)

    self.terminated = false
    self.terminate_reason = false
  end

  --- @spec #log(...): void
  function ic:log(...)
    if self.m_enable_logs then
      print(self.m_log_group, ...)
    end
  end

  --- @spec #terminate(reason: Any): void
  function ic:terminate(reason)
    self:log("terminated")
    self.terminated = true
    self.terminate_reason = reason or 'shutdown'
  end

  --- @spec #get_cluster_groups(): Table
  function ic:get_cluster_groups()
    return {
      [self.m_cluster_group] = 1,
      cluster_symbol_id = self.m_cluster_symbol_id,
    }
  end

  --- @spec &register_system(id: String, callback: Function/3): void
  function ic:register_system(id, callback)
    clusters:register_system(self.m_cluster_group, id, callback)
  end

  --- @spec #get_node_cluster(pos: Vector3): nil | Cluster
  function ic:get_node_cluster(pos)
    assert(pos, "expected node position")

    return clusters:reduce_node_clusters(pos, nil, function (cluster, acc)
      if cluster.groups[self.m_cluster_group] then
        return false, cluster
      else
        return true, acc
      end
    end)
  end

  --- @spec #get_node_cluster_by_id(id: Integer): nil | Cluster
  function ic:get_node_cluster_by_id(id)
    return clusters:reduce_node_clusters_by_id(id, nil, function (cluster, acc)
      if cluster.groups[self.m_cluster_group] then
        return false, cluster
      else
        return true, acc
      end
    end)
  end

  --- @spec #get_node(pos: Vector3): nil | ClusterNode
  function ic:get_node(pos)
    local cluster = self:get_node_cluster(pos)

    if cluster then
      return cluster:get_node(pos)
    end

    return nil
  end

  --- @spec #get_node_by_id(id: Integer): nil | ClusterNode
  function ic:get_node_by_id(id)
    local cluster = self:get_node_cluster_by_id(id)

    if cluster then
      return cluster:get_node_by_id(id)
    end

    return nil
  end

  --- @overridable
  --- @spec #get_node_infotext(Vector3): String
  function ic:get_node_infotext(pos)
    assert(pos, "expected node position")

    local node_id = minetest.hash_node_position(pos)

    return clusters:reduce_node_clusters(pos, '', function (cluster, acc)
      if cluster.groups[self.m_cluster_group] then
        return false, "Simple Cluster: " .. cluster.id
      else
        return true, acc
      end
    end)
  end

  --- @overridable
  function ic:get_node_groups(node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef and nodedef.simple_network then
      return nodedef.simple_network.groups or {}
    else
      return {}
    end
  end

  --- @spec #schedule_add_node(pos: Vector3, node: NodeRef): void
  function ic:schedule_add_node(pos, node)
    self:log("schedule_add_node", minetest.pos_to_string(pos), node.name)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef.groups[self.m_node_group] then
      local groups = self:get_node_groups(node)
      clusters:schedule_node_event(
        self.m_cluster_group,
        "add_node",
        pos,
        copy_node(node),
        { groups = groups }
      )
    else
      error("node violation: " .. node_to_string(node) .. " does not belong to " .. self.m_node_group .. " group")
    end
  end

  -- Transitions should be scheduled when a node intends to change it's state but doesn't need to
  -- do so immediately, an example would be a combustion engine that needs to update it's texture
  -- to show it's on/off state.
  --
  -- Args:
  -- * `pos` - the position of the node
  -- * `node` - the NodeRef
  -- * `new_state` - some kind of identifier for the new state, could be anything
  function ic:schedule_transition_node(pos, node, new_state, reason)
    self:log("schedule_transition_node", minetest.pos_to_string(pos), node.name)
    local groups = self:get_node_groups(node)
    clusters:schedule_node_event(
      self.m_cluster_group,
      "transition_node",
      pos,
      copy_node(node),
      { state = new_state, reason = reason }
    )
  end

  function ic:schedule_load_node(pos, node, reason)
    self:log("schedule_load_node", minetest.pos_to_string(pos), node.name)
    local groups = self:get_node_groups(node)
    clusters:schedule_node_event(
      self.m_cluster_group,
      "load_node",
      pos,
      copy_node(node),
      { groups = groups, reason = reason }
    )
  end

  function ic:schedule_update_node(pos, node, reason)
    self:log("schedule_update_node", minetest.pos_to_string(pos), node.name)
    local groups = self:get_node_groups(node)
    clusters:schedule_node_event(
      self.m_cluster_group,
      "update_node",
      pos,
      copy_node(node),
      { groups = groups, reason = reason }
    )
  end

  function ic:schedule_remove_node(pos, node, reason)
    self:log("schedule_remove_node", minetest.pos_to_string(pos), node.name)
    clusters:schedule_node_event(
      self.m_cluster_group,
      "remove_node",
      pos,
      copy_node(node),
      { reason = reason }
    )
  end

  function ic:handle_node_event(cls, generation_id, event, cluster_ids, trace)
    local span

    self:log("event", event.event_name, generation_id, minetest.pos_to_string(event.pos))

    if trace then
      span = trace:span_start(event.event_name)
    end

    if event.event_name == "load_node" then
      -- treat loads like adding a node
      self:_handle_load_node(cls, generation_id, event, cluster_ids)

    elseif event.event_name == "add_node" then
      self:_handle_add_node(cls, generation_id, event, cluster_ids)

    elseif event.event_name == "update_node" then
      self:_handle_update_node(cls, generation_id, event, cluster_ids)

    elseif event.event_name == "remove_node" then
      self:_handle_remove_node(cls, generation_id, event, cluster_ids)

    elseif event.event_name == "transition_node" then
      self:_handle_transition_node(cls, generation_id, event, cluster_ids)

    else
      self:log("unhandled event event_name=" .. event.event_name)
    end

    if span then
      span:span_end()
    end
  end

  function ic:get_node_color(node)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef and nodedef.yatm_network then
      return nodedef.yatm_network.color or 'default'
    end
    return nil
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
    local npos
    local cluster
    local node_entry
    local other_color

    if cluster_ids and not is_table_empty(cluster_ids) then
      for dir6, vec3 in pairs(DIR6_TO_VEC3) do
        npos = vector.add(origin, vec3)

        for cluster_id, _ in pairs(cluster_ids) do
          cluster = cls:get_cluster(cluster_id)
          if cluster then
            node_entry = cluster:get_node(npos)

            if node_entry then
              other_color = self:get_node_color(node_entry.node)

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

  function ic:_handle_load_node(cls, generation_id, event, given_cluster_ids)
    self:log('_handle_load_node', minetest.pos_to_string(event.pos))
    return self:_handle_add_node(cls, generation_id, event, given_cluster_ids)
  end

  function ic:_handle_add_node(cls, generation_id, event, given_cluster_ids)
    self:log('_handle_add_node', minetest.pos_to_string(event.pos))
    local neighbours = self:find_compatible_neighbours(cls, event.pos, event.node, given_cluster_ids)

    local needs_full_refresh = false

    local cluster
    if is_table_empty(neighbours) then
      -- need a new cluster for this node
      cluster = cls:create_cluster(self:get_cluster_groups())
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
        needs_full_refresh = true
      end
    end

    cls:add_node_to_cluster(cluster.id, event.pos, event.node, event.params.groups)

    yatm.queue_refresh_infotext(event.pos, event.node)

    cluster.assigns.generation_id = generation_id

    if needs_full_refresh then
      cluster:reduce_nodes(0, function (node_entry, acc)
        yatm.queue_refresh_infotext(node_entry.pos, node_entry.node)
        return true, acc + 1
      end)
    end

    return cluster
  end

  function ic:_handle_update_node(cls, generation_id, event, given_cluster_ids)
    self:log('_handle_update_node', minetest.pos_to_string(event.pos))
    local cluster
    local other_cluster

    local group_value
    for cluster_id, _ in pairs(given_cluster_ids) do
      other_cluster = cls:get_cluster(cluster_id)
      group_value = other_cluster.groups[self.m_cluster_group]
      if other_cluster and group_value and group_value > 0 then
        cluster = other_cluster
        break
      end
    end

    if cluster then
      -- local updated, err =
        cls:update_node_in_cluster(cluster.id, event.pos, event.node, event.params.groups)

      -- if not updated then
        -- minetest.log("warning", "failed to update node " .. dump(event) .. err)
      -- end
    end
    return cluster
  end

  function ic:mark_accessible_dirs(pos, node, accessible_dirs)
    local color = self:get_node_color(node)
    local npos
    local nnode
    local rating
    local other_color

    for dir6, vec3 in pairs(DIR6_TO_VEC3) do
      npos = vector.add(pos, vec3)
      nnode = minetest.get_node_or_nil(npos)

      if nnode then
        rating = minetest.get_item_group(nnode.name, self.m_node_group)
        if rating and rating > 0 then
          other_color = self:get_node_color(nnode)

          if self:is_compatible_colors(color, other_color) then
            -- okay
          else
            --print("dir is inaccesible, not a compatible color",
            --      minetest.pos_to_string(npos), nnode.name, dump(color), dump(other_color))
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

  function ic:scan_for_branches(scan_origin, _scan_node)
    local all_nodes = {}
    local branches = {}
    local hash_node_position = minetest.hash_node_position

    local origin = scan_origin
    local g_branch_id = 0
    local branch_id
    local nodes
    local current_node_id
    local nodedef
    local other_branch_id
    local other_branches
    local new_nodes

    for dir6, vec3 in pairs(DIR6_TO_VEC3) do
      g_branch_id = g_branch_id + 1
      origin = vector.add(origin, vec3)

      branch_id = g_branch_id
      nodes = {}
      branches[branch_id] = nodes

      yatm.explore_nodes(origin, 0, function (pos, node, acc, accessible_dirs)
        current_node_id = hash_node_position(pos)
        if nodes[current_node_id] then
          return false, acc
        end

        nodedef = minetest.registered_nodes[node.name]
        if nodedef then
          if nodedef.groups[self.m_node_group] then
            if all_nodes[current_node_id] then
              other_branch_id = all_nodes[current_node_id]
              other_branches = branches[other_branch_id]

              if nodes ~= other_branches then
                new_nodes = {}
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
              all_nodes[current_node_id] = branch_id
              nodes[current_node_id] = branch_id
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
    self:log('_handle_remove_node', minetest.pos_to_string(event.pos))

    local current_cluster = self:get_node_cluster(event.pos)

    if current_cluster then
      cls:remove_node_from_cluster(current_cluster.id, event.pos, event.node)
    end

    local branches = self:scan_for_branches(event.pos, event.node)

    local affected_clusters = {}
    local branch_id_to_cluster_id = {}
    local pos
    local cluster_id
    local cluster
    local node

    for branch_id, nodes in pairs(branches) do
      for node_id, _ in pairs(nodes) do
        pos = minetest.get_position_from_hash(node_id)

        cluster_id =
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
        cluster = cls:create_cluster(self:get_cluster_groups())

        for node_id, _ in pairs(nodes) do
          pos = minetest.get_position_from_hash(node_id)
          node = minetest.get_node(pos)

          cls:add_node_to_cluster(cluster.id, pos, node, self:get_node_groups(node))
          yatm.queue_refresh_infotext(pos, node)
        end

        self:on_cluster_branch_changed(cls, generation_id, event, cluster)
      end
    end
  end

  function ic:on_cluster_branch_changed(cls, generation_id, event, cluster)
  end

  function ic:_handle_transition_node(cls, generation_id, event, _cluster_ids)
    local node = minetest.get_node_or_nil(event.pos)
    if node then
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef.transition_device_state then
        nodedef.transition_device_state(event.pos, node, event.params.state, "simple_cluster:transition_node")
      else
        self.log("_handle_transition_node",
                 "WARN: nodedef does not have transition_device_state node_name=" .. node.name)
      end
    else
      self.log("_handle_transition_node",
               "WARN: node does not exist pos=" .. minetest.pos_to_string(event.pos))
    end
  end

  local fspec = assert(foundation.com.formspec.api)

  ---
  --- Helper function for rendering cluster members in the cluster tool
  ---
  --- Usage:
  ---   yatm.cluster_tool.register_cluster_tool_render(
  ---     CLUSTER_GROUP,
  ---     simple_cluster_instance:method("cluster_tool_render")
  ---   )
  ---
  --- Args:
  --- * `cluster` - a Clusters.Cluster instance
  --- * `formspec` - the formspec from the cluster tool render process
  --- * `render_state` - state map containing the cluster information
  function ic:cluster_tool_render(cluster, formspec, render_state)
    local registered_nodes_with_count =
      cluster:reduce_nodes({}, function (node_entry, acc)
        if not acc[node_entry.node.name] then
          acc[node_entry.node.name] = {
            count = 0,
          }
        end
        local item = acc[node_entry.node.name]
        item.count = (item.count or 0) + 1
        item.last_entry = node_entry

        return true, acc
      end)

    local cols = 6
    local colsize = render_state.w / cols
    local item_size = colsize * 0.6
    local label_size = colsize * 0.6
    local i = 0
    local x
    local y

    local last_energy_produced

    for node_name, item in pairs(registered_nodes_with_count) do
      x = math.floor(i % cols) * colsize
      y = math.floor(i / cols) * colsize

      last_energy_produced = item.last_entry.assigns.last_energy_produced or "N/A"

      formspec =
        formspec ..
        fspec.item_image(x, 0.5 + y, item_size, item_size, node_name) ..
        fspec.label(x + label_size, y, item.count) ..
        fspec.tooltip_area(x, y, item_size, item_size, last_energy_produced)

      i = i + 1
    end

    return formspec
  end
end

yatm_clusters.SimpleCluster = SimpleCluster
