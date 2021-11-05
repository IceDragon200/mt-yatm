local is_table_empty = assert(foundation.com.is_table_empty)
local table_keys = assert(foundation.com.table_keys)
local table_length = assert(foundation.com.table_length)
local Directions = assert(foundation.com.Directions)
local facedir_to_face = assert(Directions.facedir_to_face)
local DIR6_TO_VEC3 = assert(Directions.DIR6_TO_VEC3)

local ReactorCluster = yatm_clusters.SimpleCluster:extends("ReactorCluster")
local ic = ReactorCluster.instance_class

function ic:initialize(cluster_group)
  ic._super.initialize(self, {
    cluster_group = cluster_group,
    log_group = 'yatm.cluster.reactor',
    node_group = 'yatm_cluster_reactor'
  })
end

function ic:schedule_start_reactor(pos, node, player_name)
  print(self.m_log_group, 'schedule_start_reactor', minetest.pos_to_string(pos), node.name)
  yatm.clusters:schedule_node_event(self.m_cluster_group, 'start_reactor', pos, node, { player_name = player_name })
end

function ic:schedule_stop_reactor(pos, node, player_name)
  print(self.m_log_group, 'schedule_stop_reactor', minetest.pos_to_string(pos), node.name)
  yatm.clusters:schedule_node_event(self.m_cluster_group, 'stop_reactor', pos, node, { player_name = player_name })
end

function ic:schedule_remove_node(pos, node)
  return ic._super.schedule_remove_node(self, pos, node)
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

  elseif event.event_name == 'start_reactor' then
    self:_handle_start_reactor(cls, generation_id, event, cluster_ids)

  elseif event.event_name == 'stop_reactor' then
    self:_handle_stop_reactor(cls, generation_id, event, cluster_ids)

  elseif event.event_name == 'transition_state' then
    self:_handle_transition_state(cls, generation_id, event, cluster_ids)

  else
    print(self.m_log_group, "unhandled event event_name=" .. event.event_name)
  end
end

function ic:transition_cluster_state(cls, cluster, generation_id, event, state)
  cls:schedule_node_event(self.m_cluster_group, 'transition_state',
                          event.pos, event.node,
                          {
                            state = state,
                            cluster_id = cluster.id,
                            generation_id = generation_id
                          })
end

local function linear_explore(size_limit, origin, cluster, dir)
  local hash_node_position = minetest.hash_node_position

  local total_distance = 0
  local last_pos = origin
  local to_visit = {origin}
  local seen = {}
  local valid = true
  local old_to_visit
  local next_pos

  while #to_visit > 0 do
    if not valid then
      break
    end

    old_to_visit = to_visit
    to_visit = {}

    for _,pos in ipairs(old_to_visit) do
      if cluster:get_node(pos) then
        last_pos = pos
        total_distance = total_distance + 1

        if pos.w and pos.w > size_limit then
          valid = false
          break
        end

        next_pos = vector.add(pos, DIR6_TO_VEC3[dir])

        next_pos.w = (pos.w or 0) + 1

        table.insert(to_visit, next_pos)
      end
    end
  end

  return {
    distance = total_distance,
    origin = origin,
    pos = last_pos,
    valid = valid
  }
end

local function lateral_explore(size_limit, origin, cluster, left_dir, right_dir)
  local hash_node_position = minetest.hash_node_position

  local total_distance = 0
  local reactor_left = origin
  local reactor_right = origin
  local to_visit = {origin}
  local seen = {}
  local valid = true

  while #to_visit > 0 do
    if not valid then
      break
    end

    local old_to_visit = to_visit
    to_visit = {}

    for _,pos in ipairs(old_to_visit) do
      local hash = hash_node_position(pos)

      if not seen[hash] then
        seen[hash] = true

        if cluster:get_node(pos) then
          total_distance = total_distance + 1

          if (pos.l or 0) > size_limit then
            valid = false
            break
          end

          if pos.w then
            if pos.w < 0 then
              reactor_left = pos
            elseif pos.w > 0 then
              reactor_right = pos
            end
          end

          local left = vector.add(pos, DIR6_TO_VEC3[left_dir])
          local right = vector.add(pos, DIR6_TO_VEC3[right_dir])

          left.l = (pos.l or 0) + 1
          left.w = -1

          right.l = (pos.l or 0) + 1
          right.w = 1

          table.insert(to_visit, left)
          table.insert(to_visit, right)
        end
      end
    end
  end

  return {
    distance = total_distance,
    origin = origin,
    left = reactor_left,
    right = reactor_right,
    valid = valid
  }
end

local function extents_from_explored(w, h, d)
  local x1 = math.min(d.pos.x, math.min(h.right.x, math.min(h.left.x, math.min(w.left.x, w.right.x))))
  local x2 = math.max(d.pos.x, math.max(h.right.x, math.max(h.left.x, math.max(w.left.x, w.right.x))))

  local y1 = math.min(d.pos.y, math.min(h.right.y, math.min(h.left.y, math.min(w.left.y, w.right.y))))
  local y2 = math.max(d.pos.y, math.max(h.right.y, math.max(h.left.y, math.max(w.left.y, w.right.y))))

  local z1 = math.min(d.pos.z, math.min(h.right.z, math.min(h.left.z, math.min(w.left.z, w.right.z))))
  local z2 = math.max(d.pos.z, math.max(h.right.z, math.max(h.left.z, math.max(w.left.z, w.right.z))))

  return vector.new(x1, y1, z1), vector.new(x2, y2, z2)
end

function ic:verify_reactor_structure(cls, generation_id, event, cluster)
  local controllers = cluster:get_nodes_of_group("controller")

  local controller_node_entry = controllers[1]

  -- The controller's position
  local origin = controller_node_entry.pos

  -- node_entry.node may be a stale entry
  local node = minetest.get_node(origin)

  -- Grab all the directions for the reactor controller
  -- the SOUTH face is always the 'front' (the face that you preceive to be the front)
  local north_dir = facedir_to_face(node.param2, Directions.D_NORTH)
  -- The NORTH face is the 'back'
  local south_dir = facedir_to_face(node.param2, Directions.D_SOUTH)
  -- the other sides
  local east_dir = facedir_to_face(node.param2, Directions.D_EAST)
  local west_dir = facedir_to_face(node.param2, Directions.D_WEST)
  local up_dir = facedir_to_face(node.param2, Directions.D_UP)
  local down_dir = facedir_to_face(node.param2, Directions.D_DOWN)

  -- The first rule is, a reactor controller MUST be sorrounded by
  -- 'structure' reactor nodes, that is glass, panels or casings.
  -- You can use all glass for your reactor, if you'd like, I ain't complaining!
  -- Also the north face must be 'empty', well coolant is allowed, but otherwise EMPTY.
  local east_struct = cluster:get_node_group(vector.add(origin, DIR6_TO_VEC3[east_dir]), 'structure')
  local west_struct = cluster:get_node_group(vector.add(origin, DIR6_TO_VEC3[west_dir]), 'structure')
  local up_struct = cluster:get_node_group(vector.add(origin, DIR6_TO_VEC3[up_dir]), 'structure')
  local down_struct = cluster:get_node_group(vector.add(origin, DIR6_TO_VEC3[down_dir]), 'structure')

  local north_node = minetest.get_node(vector.add(origin, DIR6_TO_VEC3[north_dir]))

  local north_has_air_or_coolant =
    north_node.name == 'air' or
    minetest.get_item_group(north_node.name, 'reactor_coolant') or
    minetest.get_item_group(north_node.name, 'coolant') or
    minetest.get_item_group(north_node.name, 'air')

  if east_struct and west_struct and up_struct and down_struct then
    if not north_has_air_or_coolant then
      return false, 'behind the controller should be coolant or air'
    end
  else
    return false, 'reactor controller is missing structural nodes'
  end

  local size_limit = 16

  -- Next step, determine width of reactor itself
  -- This is done by grabbing it's farmost left and farmost right node on the same
  -- vertical line as the controller
  -- It cannot exceed 16 blocks from the controller
  local w = lateral_explore(size_limit, origin, cluster, east_dir, west_dir)
  if not w.valid then
    return false, 'explorable reactor width exceeded'
  end

  if w.distance > size_limit then
    return false, 'reactor width exceeded'
  end

  -- Next step, determine height of reactor itself
  local h = lateral_explore(size_limit, origin, cluster, up_dir, down_dir)
  if not h.valid then
    return false, 'explorable reactor height exceeded'
  end

  if h.distance > size_limit then
    return false, 'reactor height exceeded'
  end

  -- Next step, determine the depth of the reactor,
  --   that is the number of nodes behind the controller, till the next reactor node
  -- this can be obtained by just grabbing any of the corner pos and tracing a route backwards (i.e. north_dir)
  -- grab the width left point for this, just because
  local d = linear_explore(size_limit, w.left, cluster, north_dir)

  if not d.valid then
    return false, 'explorable reactor depth exceeded'
  end

  if d.distance > size_limit then
    return false, 'reactor depth exceeded'
  end

  local va, vb = extents_from_explored(w, h, d)
  local seen_nodes = {}

  -- Now we know all the edges, but it's not completely valid yet
  -- Next step, do a cuboid face test

  -- This loop handles the front and back faces
  local valid = true
  for y = va.y,vb.y do
    for x = va.x,vb.x do
      local node_entry = cluster:get_node(vector.new(x, y, va.z))
      if node_entry then
        seen_nodes[node_entry.id] = true
      else
        valid = false
        break
      end

      local node_entry = cluster:get_node(vector.new(x, y, vb.z))
      if node_entry then
        seen_nodes[node_entry.id] = true
      else
        valid = false
        break
      end
    end
  end

  if not valid then
    return false, "front or back faces of the reactor are invalid"
  end

  -- This loop handles the side faces
  for y = va.y,vb.y do
    for z = va.z,vb.z do
      local node_entry = cluster:get_node(vector.new(va.x, y, z))
      if node_entry then
        seen_nodes[node_entry.id] = true
      else
        valid = false
        break
      end

      local node_entry = cluster:get_node(vector.new(vb.x, y, z))
      if node_entry then
        seen_nodes[node_entry.id] = true
      else
        valid = false
        break
      end
    end
  end

  if not valid then
    return false, "side faces of the reactor are invalid"
  end

  -- This loop handles the top and bottom faces
  for x = va.x,vb.x do
    for z = va.z,vb.z do
      local node_entry = cluster:get_node(vector.new(x, va.y, z))
      if node_entry then
        seen_nodes[node_entry.id] = true
      else
        valid = false
        break
      end

      local node_entry = cluster:get_node(vector.new(x, vb.y, z))
      if node_entry then
        seen_nodes[node_entry.id] = true
      else
        valid = false
        break
      end
    end
  end

  if not valid then
    return false, "side faces of the reactor are invalid"
  end

  -- Next step, ensure that the interior of the reactor is hollow (contains air or coolant only.)
  -- Just need to sort all the points
  -- adjust the extents so that they are 1 less
  local hva = vector.add(va, 1)
  local hvb = vector.subtract(va, 1)

  -- Perform cuboid loop, doing layer by layer
  local is_hollow = true
  for y = hva.y,hvb.y do
    for z = hva.z,hvb.z do
      for x = hva.x,hvb.x do
        local inner_node = minetest.get_node(vector.new(x, y, z))

        is_hollow =
          inner_node.name == 'air' or
          minetest.get_item_group(inner_node.name, 'reactor_coolant') or
          minetest.get_item_group(inner_node.name, 'coolant') or
          minetest.get_item_group(inner_node.name, 'air')

        if not is_hollow then
          break
        end
      end
      if not is_hollow then
        break
      end
    end
    if not is_hollow then
      break
    end
  end

  if not is_hollow then
    return false, 'reactor is not hollow'
  end

  -- Finally, lint the nodes, all explored nodes should also be all the registered nodes
  -- If either map is a missing something the reactor has an extraneous node.
  -- the quickest way to test this is just check the size of the cluster against all the explored nodes.
  if table_length(seen_nodes) ~= cluster:size() then
    return false, 'reactor appears to be malformed, not all nodes were seen in the cluster'
  end

  return true, 'ok'
end

function ic:_handle_start_reactor(cls, generation_id, event, cluster_ids)
  assert(cluster_ids, "expected cluster_ids")
  local cluster
  for cluster_id, _ in pairs(cluster_ids) do
    local ncluster = cls:get_cluster(cluster_id)
    if ncluster then
      if ncluster.groups[self.m_cluster_group] then
        cluster = ncluster
        break
      end
    end
  end

  if cluster then
    local controllers = cluster:get_nodes_of_group("controller")
    local controller_count = #controllers
    if controller_count == 0 then
      -- Possibly caused by a signalling event
      -- Off you go.
      self:transition_cluster_state(cls, cluster, generation_id, event, 'off')
    elseif controller_count == 1 then
      -- Just the right number - naise
      -- Need to determine structural integrity now
      local valid, err = self:verify_reactor_structure(cls, generation_id, event, cluster)
      if valid then
        minetest.chat_send_player(event.params.player_name, "Reactor started")
        self:transition_cluster_state(cls, cluster, generation_id, event, 'on')
      else
        print("Reactor is invalid reason=" .. err)
        minetest.chat_send_player(event.params.player_name, "Reactor has failed to start reason=" .. err)
        self:transition_cluster_state(cls, cluster, generation_id, event, 'error')
      end
    elseif controller_count > 1 then
      -- Too many reactor controllers, go into a conflict state
      print("Reactor has too many controllers")
      minetest.chat_send_player(event.params.player_name, "Too many controllers in reactor cluster")
      self:transition_cluster_state(cls, cluster, generation_id, event, 'conflict')
    end
  end
end

function ic:_handle_stop_reactor(cls, generation_id, event, cluster_ids)
  local cluster
  for cluster_id, _ in pairs(cluster_ids) do
    local ncluster = cls:get_cluster(cluster_id)
    if ncluster then
      if ncluster.groups[self.m_cluster_group] then
        cluster = ncluster
        break
      end
    end
  end

  if cluster then
    self:transition_cluster_state(cls, cluster, generation_id, event, 'off')
  end
end

function ic:_handle_transition_state(cls, generation_id, event, cluster_ids)
  print(self.m_log_group, "transition_state", generation_id, 'cluster_id=' .. event.params.cluster_id, 'state=' .. event.params.state)
  local cluster = cls:get_cluster(event.params.cluster_id)
  if cluster then
    cluster.assigns.state = assert(event.params.state)
    cluster:reduce_nodes(0, function (node_entry, acc)
      local node = minetest.get_node(node_entry.pos)
      local nodedef = minetest.registered_nodes[node.name]
      if nodedef.transition_reactor_state then
        nodedef.transition_reactor_state(node_entry.pos, node, cluster.assigns.state)
      else
        print(node_entry.node.name .. " does not define a transition_reactor_state/3")
      end
      return true, acc + 1
    end)
  else
    print(self.m_log_group, "cluster requested a transition_state but it no longer exists cluster_id=" .. cluster_id)
  end
end

function ic:get_node_infotext(pos)
  local node_id = minetest.hash_node_position(pos)

  return yatm.clusters:reduce_node_clusters(pos, '', function (cluster, acc)
    if cluster.groups[self.m_cluster_group] then
      return false, "Reactor Cluster: " .. cluster.id
    else
      return true, acc
    end
  end)
end

function ic:get_node_groups(node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.reactor_device then
    return nodedef.reactor_device.groups or {}
  else
    return {}
  end
end

yatm_reactors.ReactorCluster = ReactorCluster
