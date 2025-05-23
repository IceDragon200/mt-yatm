--
-- The DATA network is a form of node cluster which keeps track of
-- DATA nodes and handles the event passing.
--
-- DATA processing is repeated up to 16 times per tick, this simulates somewhat of realtime
-- communication between nodes, allowing them to queue responses or reactions to events.
--
-- Unlike most other clusters, the DATA network is not a active member of the 'clusters'
-- system, therefore it will not show up when using reduce_node_clusters and it's other members.
--
-- DATA networks have a root network_id and then 6 sub network ids: one for each direction.
-- The root network_id behaves like any other normal cluster, the sub networks are where the
-- DATA system really works, sub nets divide a single node into 6 different branches or subnets
-- Normally identified by color AND direction (since it's possible to just use the same color
-- everywhere).
-- This is one of the main reasons why it is not registered as a normal cluster.
--
-- A network is formed from 3 main components:
--   * A DATA Device - the device is the object that does the real work this can be anything
--                     ranging from a simple arithmetic unit, to a sensor
--   * A DATA Cable  - allows forming the network over a distance, they can connect together
--   * A DATA Bus    - a data bus is a cable affixed with a bus controller that allows cables to
--                     connect to a device, otherwise the cable cannot interact with the device.

local is_table_empty = assert(foundation.com.is_table_empty)
local table_equals = assert(foundation.com.table_equals)
local table_copy = assert(foundation.com.table_copy)
local Directions = assert(foundation.com.Directions)
local pos_to_string = assert(minetest.pos_to_string)
local hash_node_position = assert(minetest.hash_node_position)
local generate_network_id = assert(yatm_data_network.utils.generate_network_id)

--- @namespace yatm_data_network

--- @class DataNetwork
local DataNetwork = foundation.com.Class:extends('yatm_data_network.DataNetwork')

DataNetwork.PORT_RANGE = 16
DataNetwork.COLOR_RANGE = {
-- name      = { offset = integer, range = integer}
  multi      = { offset = 0,   range = DataNetwork.PORT_RANGE * 16},
  white      = { offset = 0,   range = DataNetwork.PORT_RANGE},
  grey       = { offset = 16,  range = DataNetwork.PORT_RANGE},
  dark_grey  = { offset = 32,  range = DataNetwork.PORT_RANGE},
  black      = { offset = 48,  range = DataNetwork.PORT_RANGE},
  violet     = { offset = 64,  range = DataNetwork.PORT_RANGE},
  blue       = { offset = 80,  range = DataNetwork.PORT_RANGE},
  light_blue = { offset = 96,  range = DataNetwork.PORT_RANGE},
  cyan       = { offset = 112, range = DataNetwork.PORT_RANGE},
  dark_green = { offset = 128, range = DataNetwork.PORT_RANGE},
  green      = { offset = 144, range = DataNetwork.PORT_RANGE},
  yellow     = { offset = 160, range = DataNetwork.PORT_RANGE},
  brown      = { offset = 176, range = DataNetwork.PORT_RANGE},
  orange     = { offset = 192, range = DataNetwork.PORT_RANGE},
  red        = { offset = 208, range = DataNetwork.PORT_RANGE},
  magenta    = { offset = 224, range = DataNetwork.PORT_RANGE},
  pink       = { offset = 240, range = DataNetwork.PORT_RANGE},
}

do
  local ic = assert(DataNetwork.instance_class)

  --- @type InitOptions: {
  ---   clusters: yatm_clusters.Clusters,
  ---   world: Minetest,
  --- }

  --- Initializes a DataNetwork, the options must have a reference to the clusters instance and
  --- a world-like object.
  --- `clusters` will be used to subscribe to block expiration events.
  --- `world` acts as the primary target for the get/set node functions.
  ---
  --- @spec #initialize(options: InitOptions): void
  function ic:initialize(options)
    local clusters = assert(options.clusters, "clusters instance is required")
    local world = assert(options.world, "a world instance is required")
    self.world = world
    self.terminated = false
    self.terminate_reason = false

    self.m_cluster_symbol_id = foundation.com.Symbols:symbol_to_id('yatm_data')

    self.m_elapsed = 0
    self.m_counter = 0
    self.m_queued_refreshes = {}
    self.m_networks = {}
    self.m_sub_networks = {}
    self.m_members = {}
    self.m_members_by_group = {}
    self.m_block_members = {}
    self.m_resolution_id = 0

    local service_id = "yatm_data_network:DataNetwork#unload_block"
    self.disregard_clusters = clusters:observe(
      "on_block_expired", -- event
      service_id,
      self:method("unload_block")
    )
  end

  --- @spec #init(): void
  function ic:init()
    self:log("initializing")
    self:log("initialized")
  end

  --- @spec #terminate(reason: String): void
  function ic:terminate(reason)
    --
    self:log("terminating", reason)
    -- release everything
    self.disregard_clusters()
    self.disregard_clusters = nil
    self.m_queued_refreshes = {}
    self.m_networks = {}
    self.m_members = {}
    self.m_members_by_group = {}
    self.terminated = true
    self.terminate_reason = reason
    self:log("terminated")
  end

  --- @spec #update(dt: Float): void
  function ic:update(dt)
    self.m_elapsed = self.m_elapsed + dt
    self.m_counter = self.m_counter + 1
    if not is_table_empty(self.m_queued_refreshes) then
      self.m_resolution_id = self.m_resolution_id + 1
      self:log("starting queued refreshes", "resolution_id=" .. self.m_resolution_id)

      local queued_refreshes = self.m_queued_refreshes
      self.m_queued_refreshes = {}

      for hash, event in pairs(queued_refreshes) do
        if not event.cancelled then
          --self:log("refreshing from position", pos_to_string(event.pos))
          self:refresh_from_pos(event.pos)
        end
      end
    end

    if dt > 0 then
      for network_id, network in pairs(self.m_networks) do
        self:update_network(network, dt)
      end
    end
  end

  --- @spec #log(...String): void
  function ic:log(...)
    --print("yatm.data_network", self.m_counter, ...)
  end

  function ic:get_port_offset_for_color(color)
    return DataNetwork.COLOR_RANGE[color].offset
  end

  function ic:get_port_range_for_color(color)
    return DataNetwork.COLOR_RANGE[color].range
  end

  function ic:local_port_to_net_port(local_port, color)
    assert(local_port, "expected a local port")
    assert(color, "expected a color")
    return self:get_port_offset_for_color(color) + local_port
  end

  function ic:net_port_to_local_port(net_port, color)
    assert(net_port, "expected a global port")
    assert(color, "expected a color")
    return net_port - self:get_port_offset_for_color(color)
  end

  function ic:get_infotext(pos)
    local network_id = self:get_network_id(pos)
    local member_id = hash_node_position(pos)

    local network_id_str = network_id
    local member
    local color

    local DIR_TO_STRING = Directions.DIR_TO_STRING

    if network_id then
      member = self.m_members[member_id]
      if member then
        if member.type == "device" then
          for dir, sub_network_id in pairs(member.sub_network_ids) do
            color = self:get_attached_color(pos, dir)
            if color then
              network_id_str =  network_id_str .. "\n" ..
                                DIR_TO_STRING[dir] .. "=" ..
                                "sub:" .. sub_network_id ..
                                "(" .. color .. ":" ..
                                       self:get_port_offset_for_color(color) .. ":" ..
                                       self:get_port_range_for_color(color) ..
                                ")"
            end
          end
        else
          color = member.color
          network_id_str = network_id_str .. "\n" ..
                           "sub:" .. (member.sub_network_id or "no-subnet") ..
                           "(" .. color .. ":" ..
                                  self:get_port_offset_for_color(color) .. ":" ..
                                  self:get_port_range_for_color(color) ..
                           ")"
        end
      end
    else
      network_id_str = "NULL"
    end

    return "Data.N: " .. network_id_str
  end

  --- Call this from a node to emit a value unto it's network on a specified port
  --- You can emit on any port, doesn't mean anyone will receive your value.
  ---
  --- @spec #send_value(pos: Vector3, dir: Direction, local_port: Integer, value: String): self
  function ic:send_value(pos, dir, local_port, value)
    --self:log("send_value", pos_to_string(pos), dir, local_port, dump(value))
    local member_id = hash_node_position(pos)
    local member = self.m_members[member_id]
    if member and member.network_id then
      self:_send_value_to_network(member.network_id, member_id, dir, local_port, value)
    end
    return self
  end

  function ic:unmark_ready_to_receive(pos, dir, local_port)
    assert(pos, "expected a position")
    local member_id = hash_node_position(pos)
    local member = self.m_members[member_id]
    if member and member.network_id then
      self:_unmark_ready_to_receive_in_network(member.network_id, member_id, dir, local_port)
    end
    return self
  end

  function ic:mark_ready_to_receive(pos, dir, local_port, state)
    local member_id = hash_node_position(pos)
    local member = self.m_members[member_id]
    if member and member.network_id then
      self:_mark_ready_to_receive_in_network(member.network_id, member_id, dir, local_port, state)
    end
    return self
  end

  --- @spec #get_member(member_id: Integer): nil | DataNetworkMember
  function ic:get_member(member_id)
    return self.m_members[member_id]
  end

  --- @spec #get_member_at_pos(pos: Vector3): nil | DataNetworkMember
  function ic:get_member_at_pos(pos)
    local member_id = hash_node_position(pos)
    return self:get_member(member_id)
  end

  -- Retrieves the root network id at the specified location
  -- Will return nil if there is no data network at the location
  function ic:get_network_id(pos)
    local member = self:get_member_at_pos(pos)
    if member then
      return member.network_id
    end
    return nil
  end

  -- Retrieve a network at the specified position
  function ic:get_network_at_pos(pos)
    local network_id = self:get_network_id(pos)
    if network_id then
      return self.m_networks[network_id]
    end
    return nil
  end

  -- Retrieves all the attached colors the table is indexed by the foundation Direction codes
  -- The value is the color of that specified direction, a direction will return nil if it is not
  -- connected.
  function ic:get_attached_colors(pos)
    local member = self:get_member_at_pos(pos)
    if member then
      return member.attached_colors_by_dir
    end
    return nil
  end

  ---
  --- Retrieve the color for the specified direction.
  ---
  function ic:get_attached_color(pos, dir)
    assert(pos, "expected a position")
    local attached_colors = self:get_attached_colors(pos)
    if attached_colors then
      return attached_colors[dir]
    end
    return nil
  end

  ---
  --- Retrieves all the sub network ids at specified location
  ---
  function ic:get_sub_network_ids(pos)
    assert(pos, "expected a position")
    local member = self:get_member_at_pos(pos)
    if member then
      return member.sub_network_ids
    end
    return nil
  end

  function ic:get_sub_network_id(pos, dir)
    local sub_network_ids = self:get_sub_network_ids(pos)
    if sub_network_ids then
      return sub_network_ids[dir]
    end
    return nil
  end

  function ic:get_attached(pos, dir)
    local sub_network_id = self:get_sub_network_id(pos, dir)
    local color = self:get_attached_color(pos, dir)

    return sub_network_id, color
  end

  function ic:get_sub_network_ids_by_color(pos, expected_color)
    local attached_colors = self:get_attached_colors(pos)
    local result = {}
    if attached_colors then
      for dir, color in pairs(attached_colors) do
        if color == expected_color then
          result[dir] = self:get_sub_network_id(pos, dir)
        end
      end
    end
    return result
  end

  --- @spec #get_data_interface(Vector3): (nil | DataInterface, nil | String)
  function ic:get_data_interface(pos)
    local member = self:get_member_at_pos(pos)
    if member then
      local node = self.world.get_node_or_nil(member.pos)
      if node then
        local nodedef = minetest.registered_nodes[node.name]
        return nodedef.data_interface
      else
        return nil, "node does not exist, or is unavailable"
      end
    end
    return nil, "not a valid data network member"
  end

  function ic:cancel_queued_refresh(pos)
    local hash = hash_node_position(pos)
    local entry = self.m_queued_refreshes[hash]
    if entry then
      entry.cancelled = true
    end
    return self
  end

  --- @spec #add_node(Vector3, NodeRef): self
  function ic:add_node(pos, node)
    self:log("add_node", pos_to_string(pos), node.name)
    local member_id = hash_node_position(pos)
    local member = self.m_members[member_id]
    if member then
      minetest.log("error", "cannot register " .. pos_to_string(pos) .. " " ..
                                  node.name .. " it was already registered by " ..
                                  member.node.name)
      return false
    end

    local nodedef = minetest.registered_nodes[node.name]

    -- hah dungeons and dragons... I'll see myself out
    local dnd = nodedef.data_network_device
    if not dnd then
      minetest.log("error", "cannot register " .. node.name .. " it does not have a data_network_device field defined")
      return false
    end

    member = {
      id = member_id,
      pos = pos,
      node = node,
      network_id = nil,
      groups = dnd.groups or {},
      attached_color_by_dir = {},
      sub_network_ids = {},
    }

    local block_id = yatm.clusters:mark_node_block(member.pos, member.node)
    if not self.m_block_members[block_id] then
      self.m_block_members[block_id] = {}
    end
    self.m_block_members[block_id][member_id] = true
    member.block_id = block_id
    self.m_members[member_id] = member

    self:do_register_member_groups(member)
    self:_queue_refresh(pos, "node added")
    return true
  end

  --- Call this function when the physical node has changed in order to keep the
  --- information up to date, an example would be after a minetest.swap_node call.
  ---
  --- @spec #update_member(Vector3, NodeRef, Boolean): self
  function ic:update_member(pos, node, force_refresh)
    self:log("update_member/3 pos=" .. pos_to_string(pos) ..
                           " name=" .. node.name ..
                           " force_refresh=" .. dump(force_refresh))
    local member_id = hash_node_position(pos)
    local member = self.m_members[member_id]
    if member then
      local need_refresh = false
      local nodedef = minetest.registered_nodes[node.name]
      local dnd = assert(nodedef.data_network_device)

      if dnd.color ~= member.color then
        member.color = dnd.color
        need_refresh = true
      end

      if not table_equals(member.accessible_dirs, dnd.accessible_dirs) then
        member.accessible_dirs = nil
        if dnd.accessible_dirs then
          member.accessible_dirs = table_copy(dnd.accessible_dirs)
        end
        need_refresh = true
      end

      local new_groups = dnd.groups or {}
      if not table_equals(member.groups, dnd.groups) then
        self:do_unregister_member_groups(member)
        member.groups = new_groups
        need_refresh = true
        self:do_register_member_groups(member)
      end

      member.node = table_copy(node)

      yatm.clusters:mark_node_block(member.pos, member.node)
      if need_refresh or force_refresh then
        self:_queue_refresh(pos, "node updated")
      end
    else
      error("no such member " .. pos_to_string(pos))
    end
    return self
  end

  --- If the node is already registered this function will call update_member, if it then add_node.
  ---
  --- @spec #upsert_member(Vector3, NodeRef, Boolean): self
  function ic:upsert_member(pos, node, force_refresh)
    self:log("upsert_member", pos_to_string(pos), node.name)
    local member_id = hash_node_position(pos)
    local member = self.m_members[member_id]
    if member then
      return self:update_member(pos, node, force_refresh)
    else
      return self:add_node(pos, node)
    end
  end

  --- @spec #unregister_member(Vector3, Node | nil): self
  function ic:unregister_member(pos, node)
    self:log("unregister_member/2", "is deprecated please use remove_node/2 instead")
    return self:remove_node(pos, node)
  end

  --- @spec #remove_node(pos: Vector3): self
  function ic:remove_node(pos)
    self:_internal_remove_node(pos)
    self:_queue_refresh(pos, "removed node")
    return self
  end

  --
  --
  --
  function ic:_send_value_to_network(network_id, member_id, dir, local_port, value)
    local network = self.m_networks[network_id]
    if network then
      local member = self.m_members[member_id]
      local color = member.attached_colors_by_dir[dir]
      if color then
        local port_offset = DataNetwork.COLOR_RANGE[color]

        if local_port >= 1 and local_port <= port_offset.range then
          local global_port = port_offset.offset + local_port

          local sub_network_id = member.sub_network_ids[dir]

          if sub_network_id then
            local parent
            local child

            parent = network.ready_to_send[sub_network_id]
            if not parent then
              parent = {}
              network.ready_to_send[sub_network_id] = parent
            end
            child = parent[global_port]
            if not child then
              child = {}
              parent[global_port] = child
            end
            parent = child
            child = parent[member_id]
            if not child then
              child = {}
              parent[member_id] = child
            end
            child[dir] = value
          end
        else
          self:log(member.node.name, "port out of range",
                   local_port, "expected to be between 1 and " .. port_offset.range)
        end
      else
        --print("WARN: ", member.node.name, "does not have an attached color; cannot send")
      end
    end
    return self
  end

  function ic:_unmark_ready_to_receive_in_network(network_id, member_id, dir, local_port)
    local network = self.m_networks[network_id]
    if network then
      local member = self.m_members[member_id]
      if local_port == 0 then
        for sub_network_id, ports in pairs(network.ready_to_receive) do
          for port, port_members in pairs(ports) do
            if dir == 0 then
              port_members[member_id] = nil
            else
              if port_members[member_id] then
                port_members[member_id][dir] = nil
              end
            end
          end
        end
      else
        if member.attached_colors_by_dir[dir] then
          local port_offset = DataNetwork.COLOR_RANGE[member.attached_colors_by_dir[dir]]

          if local_port >= 1 and local_port <= port_offset.range then
            local global_port = port_offset.offset + local_port

            local sub_network_id = member.sub_network_ids[dir]

            if sub_network_id then
              if network.ready_to_receive[sub_network_id] then
                local port_members = network.ready_to_receive[sub_network_id][global_port]

                if port_members then
                  if dir == 0 then
                    port_members[member_id] = nil
                  else
                    if port_members[member_id] then
                      port_members[member_id][dir] = nil
                    end
                  end

                  if is_table_empty(port_members) then
                    network.ready_to_receive[sub_network_id][global_port] = nil
                  end

                  if is_table_empty(network.ready_to_receive[sub_network_id]) then
                    network.ready_to_receive[sub_network_id] = nil
                  end
                end
              end
            end
          else
            self:log(member.node.name, "port out of range", local_port, "expected to be between 1 and " .. port_offset.range)
          end
        else
          --print("WARN: ", member.node.name, "does not have an attached color; cannot be readied for receive")
        end
      end
    end
    return self
  end

  function ic:_mark_ready_to_receive_in_network(network_id, member_id, dir, local_port, state)
    local network = self.m_networks[network_id]
    if network then
      local member = self.m_members[member_id]
      if member.attached_colors_by_dir[dir] then
        local port_offset = DataNetwork.COLOR_RANGE[member.attached_colors_by_dir[dir]]

        if local_port >= 1 and local_port <= port_offset.range then
          local global_port = port_offset.offset + local_port

          local sub_network_id = member.sub_network_ids[dir]

          if sub_network_id then
            local parent
            local child

            parent = network.ready_to_receive[sub_network_id]
            if not parent then
              parent = {}
              network.ready_to_receive[sub_network_id] = parent
            end
            child = parent[global_port]
            if not child then
              child = {}
              parent[global_port] = child
            end
            parent = child
            child = parent[member_id]
            if not child then
              child = {}
              parent[member_id] = child
            end
            child[dir] = state
          end
        else
          self:log(member.node.name, "port out of range", local_port, "expected to be between 1 and " .. port_offset.range)
        end
      else
        --print("WARN: ", member.node.name, "does not have an attached color; cannot be readied for receive")
      end
    end
    return self
  end

  function ic:_queue_refresh(base_pos, reason)
    self:log("queue_refresh", pos_to_string(base_pos), reason)
    local base_hash = hash_node_position(base_pos)
    self.m_queued_refreshes[base_hash] = {
      pos = base_pos,
      cancelled = false,
    }

    local pos
    local hash
    for dir,v3 in pairs(Directions.DIR6_TO_VEC3) do
      pos = vector.add(base_pos, v3)
      hash = hash_node_position(pos)
      self.m_queued_refreshes[hash] = {
        pos = pos,
        cancelled = false,
      }
    end
    return self
  end

  function ic:do_unregister_member_groups(member)
    for group, _priority in pairs(member.groups) do
      if self.m_members_by_group[group] then
        self.m_members_by_group[group][member.id] = nil
      end
    end
    return self
  end

  function ic:do_register_member_groups(member)
    for group, _priority in pairs(member.groups) do
      self:log("do_register_member_groups", "registering to group", member.id, group)
      self.m_members_by_group[group] = self.m_members_by_group[group] or {}
      self.m_members_by_group[group][member.id] = true

      if member.network_id then
        local network = self.m_networks[member.network_id]
        if network then
          network.members_by_group[group] = network.members_by_group[group] or {}
          network.members_by_group[group][member.id] = true
        end
      end
    end
    return self
  end

  function ic:do_unregister_member_from_networks(member)
    if member.network_id then
      local network = self.m_networks[member.network_id]

      if network then
        if network.members[member.id] then
          network.members[member.id] = nil
          if is_table_empty(network.members) then
            self:remove_network(member.network_id)
          end
        end

        if member.sub_network_ids then
          for _dir, sub_network_id in pairs(member.sub_network_ids) do
            if network.sub_networks[sub_network_id] then
              if member.type == "device" then
                network.sub_networks[sub_network_id].devices[member.id] = nil
              elseif member.type == "bus" or
                     member.type == "mounted_bus" or
                     member.type == "cable" or
                     member.type == "mounted_cable" then
                network.sub_networks[sub_network_id].cables[member.id] = nil
              end
            end
          end
        end
      end
    end
    return self
  end

  function ic:_internal_remove_node(pos)
    self:log("unregister_member", pos_to_string(pos))
    local member_id = hash_node_position(pos)
    local entry = self.m_members[member_id]
    if entry then
      self:do_unregister_member_groups(entry)

      if entry.block_id then
        if self.m_block_members[entry.block_id] then
          self.m_block_members[entry.block_id][member_id] = nil

          if is_table_empty(self.m_block_members[entry.block_id]) then
            self.m_block_members[entry.block_id] = nil
          end
        end
      end

      self:do_unregister_member_from_networks(entry)

      self.m_members[member_id] = nil
    end
    return self
  end

  ---
  --- Clusters observation hook when a block is unloaded, triggers the removal of members from
  --- parts of the network or complete shutdown of some parts.
  ---
  function ic:unload_block(block_id)
    local member_ids = self.m_block_members[block_id]

    if member_ids then
      self.m_block_members[block_id] = nil

      local member
      for member_id,_ in pairs(member_ids) do
        member = self.m_members[member_id]

        if member then
          self:remove_node(member.pos, member.node)
        end
      end
    end
  end

  ---
  --- Removes a network, with no craps given, please don't use this unless you know what you're doing.
  ---
  function ic:remove_network(network_id)
    -- I hope you weren't expecting something spectacular.
    self.m_networks[network_id] = nil
    return self
  end

  function ic:handle_network_dispatch(network, dt)
    local attempts = 0
    local old_ready_to_send
    local old_ready_to_receive
    local subnet_receivers
    local port_receivers
    local new_receiver_dirs
    local receiver
    local receiver_node
    local nodedef
    local local_port

    local parent
    local child

    while next(network.ready_to_send) and next(network.ready_to_receive) do
      if attempts > 16 then
        break
      end
      attempts = attempts + 1

      old_ready_to_send = network.ready_to_send
      old_ready_to_receive = network.ready_to_receive

      network.ready_to_send = {}
      network.ready_to_receive = {}

      for sub_network_id, sub_network_ports in pairs(old_ready_to_receive) do
        for port, members in pairs(sub_network_ports) do
          for member_id, dirs in pairs(members) do
            for dir, state in pairs(dirs) do
              if state == "active" then
                --- this is effectively table_bury, but expanded for performance
                parent = network.ready_to_receive[sub_network_id]
                if not parent then
                  parent = {}
                  network.ready_to_receive[sub_network_id] = parent
                end
                child = parent[port]
                if not child then
                  child = {}
                  parent[port] = child
                end
                parent = child
                child = parent[member_id]
                if not child then
                  child = {}
                  parent[member_id] = child
                end
                child[dir] = state
              end
            end
          end
        end
      end

      -- yes, this purposely doesn't support multiple members sending on the same port.
      for sub_network_id, sub_network_ports in pairs(old_ready_to_send) do
        subnet_receivers = old_ready_to_receive[sub_network_id]

        if subnet_receivers then
          for port, members in pairs(sub_network_ports) do
            port_receivers = subnet_receivers[port]

            if port_receivers then
              for member_id, dirs in pairs(members) do
                for _dir, value in pairs(dirs) do
                  for receiver_member_id, receiver_dirs in pairs(port_receivers) do
                    new_receiver_dirs = {}
                    for receiver_dir, receiver_state in pairs(receiver_dirs) do
                      if receiver_state == "active" then
                        new_receiver_dirs[receiver_dir] = receiver_state
                      else
                        new_receiver_dirs[receiver_dir] = false
                      end
                      receiver = self.m_members[receiver_member_id]

                      if receiver then
                        receiver_node = self.world.get_node_or_nil(receiver.pos)

                        if receiver_node then
                          nodedef = minetest.registered_nodes[receiver_node.name]

                          if nodedef.data_interface then
                            local_port = self:net_port_to_local_port(
                              port,
                              receiver.attached_colors_by_dir[receiver_dir]
                            )
                            nodedef.data_interface:receive_pdu(receiver.pos,
                                                               receiver_node,
                                                               receiver_dir,
                                                               local_port,
                                                               value)
                          else
                            self:log("WARN: `" ..  receiver_node.name .. "` does not have a data interface")
                          end
                        end
                      end
                    end

                    for receiver_dir, receiver_state in pairs(new_receiver_dirs) do
                      if receiver_state == false then
                        receiver_dirs[receiver_dir] = nil
                      else
                        receiver_dirs[receiver_dir] = receiver_state
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  function ic:update_network(network, dt)
    --self:log("update_network", network.id, dt)

    -- Need both senders and receivers
    self:handle_network_dispatch(network, dt)

    local updatable = network.members_by_group["updatable"]
    if updatable then
      local needs_fix = false
      local member
      local node
      local nodedef

      for member_id,_is_present in pairs(updatable) do
        member = self.m_members[member_id]
        if member then
          nodedef = minetest.registered_nodes[member.node.name]
          if nodedef.data_interface then
            node = self.world.get_node_or_nil(member.pos)
            if node then
              nodedef.data_interface:update(member.pos, node, dt)
            else
              needs_fix = true
            end
          else
            self:log("WARN: Node cannot be subject to updatable group without a data_interface",
                  pos_to_string(member.pos), member.node.name)
          end
        else
          self:log("WARN: Network contains invalid member", member_id)
          needs_fix = true
        end
      end

      if needs_fix then
        local new_updatable = {}
        for member_id,value in pairs(updatable) do
          member = self.m_members[member_id]
          if member then
            new_updatable[member_id] = value
          end
        end

        network.members_by_group["updatable"] = new_updatable
      end
    end
  end

  local function compatible_colors(a, b)
    if a == "multi" or b == "multi" then
      return true
    else
      return a == b
    end
  end

  local function devices_have_compatible_colors(from_device, to_device)
    if from_device.type == "cable" or
       from_device.type == "mounted_cable" then
      -- cables can only connect to other cables or buses
      -- and they can only connect to those of the same color or a 'multi'
      if to_device.type == "bus" or
         to_device.type == "cable" or
         to_device.type == "mounted_bus" or
         to_device.type == "mounted_cable" then
        return compatible_colors(from_device.color, to_device.color)
      end
    elseif from_device.type == "bus" or
           from_device.type == "mounted_bus"  then
      -- buses can connect to cables of the same color, multi or a device and buses of the same color
      if to_device.type == "device" then
        return true
      elseif to_device.type == "cable" or
             to_device.type == "bus" or
             to_device.type == "mounted_bus" or
             to_device.type == "mounted_cable" then
        return compatible_colors(from_device.color, to_device.color)
      end
    elseif from_device.type == "device" then
      if to_device.type == "bus" or
         to_device.type == "mounted_bus" then
        return true
      end
    end
    return false, "incompatible colors"
  end

  local function can_connect_to(from_pos, from_node, from_device, origin_dir, to_pos, to_node, to_device)
    assert(origin_dir, "expected a direction")

    --[[ Debug
    local from_dir = Directions.facedir_to_local_face(from_node.param2, origin_dir)
    local to_dir = Directions.facedir_to_local_face(to_node.param2, origin_dir)

    print(table.concat({
          "FROM", pos_to_string(from_pos), from_node.name, from_node.param2, from_device.type,
          "TO", pos_to_string(to_pos), to_node.name, to_node.param2, to_device.type,
          "origin=" .. Directions.DIR_TO_STRING[origin_dir],
          "from_local=" .. Directions.DIR_TO_STRING[from_dir],
          "to_local=" .. Directions.DIR_TO_STRING[to_dir],
          }, " "))
    ]]

    if from_device.type == "mounted_cable" or
       from_device.type == "mounted_bus" then
      local local_dir = Directions.facedir_to_local_face(from_node.param2, origin_dir)
      if not from_device.accessible_dirs[local_dir] then
        return false, "originating device is not accessible in direction"
      end
    end

    if to_device.type == "mounted_cable" or
       to_device.type == "mounted_bus" then
      local inverted_dir = Directions.invert_dir(origin_dir)
      local local_dir = Directions.facedir_to_local_face(to_node.param2, inverted_dir)
      if not to_device.accessible_dirs[local_dir] then
        return false, "target device is not accessible from direction"
      end
    end

    return devices_have_compatible_colors(from_device, to_device)
  end

  function ic:refresh_from_pos(base_pos)
    --print("refresh_from_pos", pos_to_string(base_pos))
    local origin_member_id = hash_node_position(base_pos)
    local origin_member = self.m_members[origin_member_id]
    if origin_member then
      if origin_member.resolution_id == self.m_resolution_id then
        -- no need to refresh, we've already resolved from this position
        return
      end
    end

    local seen = {}
    local found = {}
    local to_check = {base_pos}

    local v3
    local old_to_check
    local hash
    local node
    local nodedef
    local device
    local other_pos
    local other_node
    local other_nodedef
    local other_device
    local valid
    local err

    while not is_table_empty(to_check) do
      old_to_check = to_check
      to_check = {}

      for _, pos in ipairs(old_to_check) do
        hash = hash_node_position(pos)

        if not seen[hash] then
          seen[hash] = true

          node = self.world.get_node(pos)
          nodedef = minetest.registered_nodes[node.name]

          if nodedef then
            device = nodedef.data_network_device

            if device then
              found[device.type] = found[device.type] or {}
              found[device.type][hash] = pos

              for dir,_ in pairs(Directions.DIR6_TO_VEC3) do
                v3 = Directions.DIR6_TO_VEC3[dir]
                other_pos = vector.add(pos, v3)
                other_node = self.world.get_node(other_pos)
                other_nodedef = minetest.registered_nodes[other_node.name]

                if other_nodedef then
                  other_device = other_nodedef.data_network_device
                  if other_device then
                    valid, err = can_connect_to(pos, node, device, dir,
                                                      other_pos, other_node, other_device)
                    if valid then
                      table.insert(to_check, other_pos)
                    else
                      if err then
                        self:log(pos_to_string(pos), pos_to_string(other_pos), err)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    -- take found nodes, and then remove their registrations if any
    -- then add the new ones
    local network_id = generate_network_id()
    -- make sure we don't already have that network
    -- I mean, what are the chances of that happening?
    while self.m_networks[network_id] do
      network_id = generate_network_id()
    end

    local network = {
      id = network_id,
      sub_networks = {},
      members = {},
      members_by_group = {},
      ready_to_send = {},
      ready_to_receive = {},
    }

    do
      local member
      local node
      local nodedef
      local block_id
      local dnd

      for device_type, devices in pairs(found) do
        for member_id, pos in pairs(devices) do
          -- go through the unregistration process, in case the node wasn't already unregistered
          self:_internal_remove_node(pos)

          member = self.m_members[member_id] or {}

          node = self.world.get_node(pos)
          nodedef = minetest.registered_nodes[node.name]
          dnd = assert(nodedef.data_network_device)

          block_id = yatm.clusters:mark_node_block(pos, node)

          member.id = member_id
          member.block_id = block_id
          member.pos = member.pos or pos
          member.node = table_copy(node)
          member.type = dnd.type
          if dnd.accessible_dirs then
            member.accessible_dirs = table_copy(dnd.accessible_dirs)
          else
            member.accessible_dirs = nil
          end
          member.color = dnd.color
          member.groups = dnd.groups or {}
          member.resolution_id = self.m_resolution_id
          member.network_id = network.id
          if member.attached_colors_by_dir then
            member.attached_colors_by_dir = table_copy(member.attached_colors_by_dir)
          else
            member.attached_colors_by_dir = {}
          end
          member.sub_network_id = nil
          member.sub_network_ids = {}

          -- Now to re-register it without the register_member function
          -- Since that includes the side effect of causing yet another refresh...
          --
          -- members are indexed by their member_id (i.e the hash)
          self.m_members[member_id] = member

          if not self.m_block_members[block_id] then
            self.m_block_members[block_id] = {}
          end
          self.m_block_members[block_id][member_id] = true

          network.members[member_id] = true
        end
      end
    end

    if not is_table_empty(network.members) then
      self:log("new data network", network.id)
      self.m_networks[network.id] = network

      local member
      local node
      local nodedef
      local other_pos
      local other_hash
      local other_member

      for member_id, _ in pairs(network.members) do
        member = self.m_members[member_id]
        self:do_register_member_groups(member)

        if member.type == "device" then
          for dir,v3 in pairs(Directions.DIR6_TO_VEC3) do
            other_pos = vector.add(member.pos, v3)
            other_hash = hash_node_position(other_pos)

            if network.members[other_hash] then
              other_member = self.m_members[other_hash]
              if other_member.type == "bus" or
                 other_member.type == "mounted_bus" then
                -- the color is used to determine what port range is usable
                -- this also affects emission
                -- each cable color has a maximum of 16 ports (1-16)
                -- the exception to this rule is the `multi`, which allows 256 (1-256)
                -- when a value is emitted on the network, it is adjusted by its color
                member.attached_colors_by_dir[dir] = other_member.color
                break
              end
            end
          end
        end

      end

      --
      self:_build_sub_networks(network)

      for member_id, _ in pairs(network.members) do
        member = self.m_members[member_id]
        node = self.world.get_node(member.pos)
        nodedef = minetest.registered_nodes[node.name]

        if nodedef then
          if nodedef.data_interface then
            -- a temporary and lazy fix to get some nodes loading corecctly
            nodedef.data_interface:on_load(member.pos, node)
          end
        end

        yatm.queue_refresh_infotext(member.pos, member.node)
      end
    end
  end

  function ic:_build_sub_networks(network)
    local member
    for member_id, _ in pairs(network.members) do
      member = self.m_members[member_id]

      -- Create subnets by buses
      if member.type == "bus" or
         member.type == "mounted_bus" then
        if not member.sub_network_id then
          self:_build_sub_network(network, member.pos)
        end
      end
    end
  end

  function ic:_explore_nodes_from_position(network, origin_pos)
    local seen = {}

    local ei = 0
    local explore = {assert(origin_pos)}
    local nodes = {}

    local old_explore
    local hash
    local member
    local vec
    local other_pos
    local other_hash
    local other_member

    while next(explore) do
      old_explore = explore
      explore = {}
      ei = 0

      for _, pos in ipairs(old_explore) do
        hash = hash_node_position(pos)

        if not seen[hash] then
          seen[hash] = true
          if network.members[hash] then
            member = self.m_members[hash]

            if member.type == "bus" or
               member.type == "cable" or
               member.type == "mounted_bus" or
               member.type == "mounted_cable" then
              nodes[hash] = true

              for dir, vec in pairs(Directions.DIR6_TO_VEC3) do
                other_pos = vector.add(pos, vec)
                other_hash = hash_node_position(other_pos)

                if network.members[other_hash] then
                  other_member = self.m_members[other_hash]
                  if other_member then
                    if can_connect_to(pos, member.node, member, dir,
                                      other_pos, other_member.node, other_member) then
                      ei = ei + 1
                      explore[ei] = other_pos
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    return nodes
  end

  function ic:_populate_sub_network(network, sub_network)
    local member
    local pos
    local hash
    local other_member
    local other_dir
    local dir
    local vec

    local sub_network_id = assert(sub_network.id)

    for member_id, _ in pairs(sub_network.cables) do
      member = self.m_members[member_id]
      member.sub_network_id = sub_network_id

      if member.type == "bus" then
        for dir, vec in pairs(Directions.DIR6_TO_VEC3) do
          pos = vector.add(member.pos, vec)
          hash = hash_node_position(pos)

          if network.members[hash] then
            other_member = self.m_members[hash]
            if other_member and other_member.type == "device" then
              sub_network.devices[hash] = true
              other_dir = Directions.invert_dir(dir)
              other_member.attached_colors_by_dir[other_dir] = member.color
              other_member.sub_network_ids[other_dir] = sub_network_id
            end
          end
        end
      elseif member.type == "mounted_bus" then
        for origin_dir, _ in pairs(member.accessible_dirs) do
          dir = Directions.facedir_to_face(member.node.param2, origin_dir)
          vec = Directions.DIR6_TO_VEC3[dir]
          pos = vector.add(member.pos, vec)
          hash = hash_node_position(pos)

          if network.members[hash] then
            other_member = self.m_members[hash]
            if other_member and other_member.type == "device" then
              sub_network.devices[hash] = true
              other_dir = Directions.invert_dir(dir)
              other_member.attached_colors_by_dir[other_dir] = member.color
              other_member.sub_network_ids[other_dir] = sub_network_id
            end
          end
        end
      end
    end
  end

  function ic:_build_sub_network(network, origin_pos)
    local nodes = self:_explore_nodes_from_position(network, origin_pos)

    local sub_network_id = generate_network_id()
    while network.sub_networks[sub_network_id] do
      sub_network_id = generate_network_id()
    end

    local sub_network = {
      id = sub_network_id,
      cables = nodes,
      devices = {}
    }

    self:log("new sub network", "network_id=" .. network.id, "sub_network_id=" .. sub_network_id)

    network.sub_networks[sub_network_id] = sub_network

    self:_populate_sub_network(network, sub_network)
  end
end

yatm_data_network.DataNetwork = DataNetwork
