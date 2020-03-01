--
--
--
local DataNetwork = yatm_core.Class:extends()
local ic = assert(DataNetwork.instance_class)

DataNetwork.PORT_RANGE = 16
DataNetwork.COLOR_RANGE = {
-- name      = { offset = integer, range = integer}
  multi      = { offset = 0,   range = DataNetwork.PORT_RANGE * 16},
  white      = { offset = 16,  range = DataNetwork.PORT_RANGE},
  grey       = { offset = 32,  range = DataNetwork.PORT_RANGE},
  dark_grey  = { offset = 48,  range = DataNetwork.PORT_RANGE},
  black      = { offset = 64,  range = DataNetwork.PORT_RANGE},
  violet     = { offset = 80,  range = DataNetwork.PORT_RANGE},
  blue       = { offset = 96,  range = DataNetwork.PORT_RANGE},
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

function ic:initialize()
  self.m_counter = 0
  self.m_queued_refreshes = {}
  self.m_networks = {}
  self.m_sub_networks = {}
  self.m_members = {}
  self.m_members_by_group = {}
  self.m_block_members = {}
  self.m_resolution_id = 0

  yatm.clusters:observe('on_block_expired', 'yatm_data_network/block_unloader', function (block_id)
    self:unload_block(block_id)
  end)
end

function ic:init()
  self:log("initializing")
  self:log("initialized")
end

function ic:terminate()
  --
  self:log("terminating")
  -- release everything
  self.m_queued_refreshes = {}
  self.m_networks = {}
  self.m_members = {}
  self.m_members_by_group = {}
  self:log("terminated")
end

function ic:update(dt)
  self.m_counter = self.m_counter + 1
  if not yatm_core.is_table_empty(self.m_queued_refreshes) then
    self.m_resolution_id = self.m_resolution_id + 1
    self:log("starting queued refreshes", "resolution_id=" .. self.m_resolution_id)

    local old_queued_refreshes = self.m_queued_refreshes
    self.m_queued_refreshes = {}

    for hash, event in pairs(old_queued_refreshes) do
      if not event.cancelled then
        --self:log("refreshing from position", minetest.pos_to_string(event.pos))
        self:refresh_from_pos(event.pos)
      end
    end
  end

  for network_id, network in pairs(self.m_networks) do
    self:update_network(network, dt)
  end
end

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
  local member_id = minetest.hash_node_position(pos)

  local network_id_str = network_id

  if network_id then
    local member = self.m_members[member_id]
    if member then
      if member.type == "device" then
        for dir, sub_network_id in pairs(member.sub_network_ids) do
          local color = self:get_attached_color(pos, dir)
          if color then
            network_id_str =  network_id_str .. "\n" ..
                              yatm_core.DIR_TO_STRING[dir] .. "=" ..
                              "sub:" .. sub_network_id ..
                              "(" .. color .. ":" ..
                                     self:get_port_offset_for_color(color) .. ":" ..
                                     self:get_port_range_for_color(color) ..
                              ")"
          end
        end
      else
        network_id_str = network_id_str .. "\n" ..
                         "sub:" .. (member.sub_network_id or "no-subnet") ..
                         "(" .. member.color .. ":" ..
                                self:get_port_offset_for_color(member.color) .. ":" ..
                                self:get_port_range_for_color(member.color) ..
                         ")"
      end
    end
  else
    network_id_str = "NULL"
  end

  return "Data.N: " .. network_id_str
end

-- Call this from a node to emit a value unto it's network on a specified port
-- You can emit on any port, doesn't mean anyone will receive your value.
function ic:send_value(pos, dir, local_port, value)
  --self:log("send_value", minetest.pos_to_string(pos), dir, local_port, dump(value))
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member and member.network_id then
    self:_send_value_to_network(member.network_id, member_id, dir, local_port, value)
  end
  return self
end

function ic:unmark_ready_to_receive(pos, dir, local_port)
  assert(pos, "expected a position")
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member and member.network_id then
    self:_unmark_ready_to_receive_in_network(member.network_id, member_id, dir, local_port)
  end
  return self
end

function ic:mark_ready_to_receive(pos, dir, local_port, state)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member and member.network_id then
    self:_mark_ready_to_receive_in_network(member.network_id, member_id, dir, local_port, state)
  end
  return self
end

function ic:get_network_id(pos)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    return member.network_id
  end
  return nil
end

function ic:get_attached_colors(pos)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    return member.attached_colors
  end
  return nil
end

function ic:get_attached_color(pos, dir)
  assert(pos, "expected a position")
  local attached_colors = self:get_attached_colors(pos)
  if attached_colors then
    return attached_colors[dir]
  end
  return nil
end

function ic:get_sub_network_ids(pos)
  assert(pos, "expected a position")
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
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

function ic:get_data_interface(pos)
  local hash = minetest.hash_node_position(pos)

  local member = self.m_members[hash]
  if member then
    local node = minetest.get_node_or_nil(member.pos)
    if node then
      local nodedef = minetest.registered_nodes[node.name]
      return nodedef.data_interface
    end
  end
  return nil
end

function ic:cancel_queued_refresh(pos)
  local hash = minetest.hash_node_position(pos)
  local entry = self.m_queued_refreshes[hash]
  if entry then
    entry.cancelled = true
  end
  return self
end

-- @spec add_node(Vector3.t, Node.t) :: DataNetwork.t
function ic:add_node(pos, node)
  self:log("add_node", minetest.pos_to_string(pos), node.name)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    error("cannot register " .. minetest.pos_to_string(pos) .. " " ..
                                node.name .. " it was already registered by " ..
                                member.node.name)
  end

  local nodedef = minetest.registered_nodes[node.name]

  -- hah dungeons and dragons... I'll see myself out
  if not nodedef.data_network_device then
    error("cannot register " .. node.name .. " it does not have a data_network_device field defined")
  end

  local dnd = assert(nodedef.data_network_device)

  member = {
    id = member_id,
    pos = pos,
    node = node,
    network_id = nil,
    groups = dnd.groups or {},
    attached_colors = {},
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
  return self
end

-- @spec update_member(Vector3.t, Node.t) :: DataNetwork.t
function ic:update_member(pos, node, force_refresh)
  self:log("update_member/3 pos=" .. minetest.pos_to_string(pos) .. " name=" .. node.name .. " force_refresh=" .. dump(force_refresh))
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    local need_refresh = false
    local nodedef = minetest.registered_nodes[node.name]
    local dnd = assert(nodedef.data_network_device)

    if dnd.color ~= member.color then
      member.color = dnd.color
      need_refresh = true
    end

    if not yatm_core.table_equals(member.accessible_dirs, dnd.accessible_dirs) then
      member.accessible_dirs = yatm_core.table_copy(dnd.accessible_dirs)
      need_refresh = true
    end

    local new_groups = dnd.groups or {}
    if not yatm_core.table_equals(member.groups, dnd.groups) then
      self:do_unregister_member_groups(member)
      member.groups = new_groups
      need_refresh = true
      self:do_register_member_groups(member)
    end

    member.node = yatm_core.table_copy(node)

    yatm.clusters:mark_node_block(member.pos, member.node)
    if need_refresh or force_refresh then
      self:_queue_refresh(pos, "node updated")
    end
  else
    error("no such member " .. minetest.pos_to_string(pos))
  end
  return self
end

function ic:upsert_member(pos, node, force_refresh)
  self:log("upsert_member", minetest.pos_to_string(pos), node.name)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    return self:update_member(pos, node, force_refresh)
  else
    return self:add_node(pos, node)
  end
end

-- @spec unregister_member(Vector3.t, Node.t | nil) :: DataNetwork.t
function ic:unregister_member(pos, node)
  self:log("unregister_member/2", "is deprecated please use remove_node/2 instead")
  return self:remove_node(pos, node)
end

function ic:remove_node(pos, node)
  self:_internal_remove_node(pos, node)
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
    local color = member.attached_colors[dir]
    if color then
      local port_offset = DataNetwork.COLOR_RANGE[color]

      if local_port >= 1 and local_port <= port_offset.range then
        local global_port = port_offset.offset + local_port

        local sub_network_id = member.sub_network_ids[dir]

        if sub_network_id then
          yatm_core.table_bury(network.ready_to_send, {sub_network_id, global_port, member_id, dir}, value)
        end
      else
        self:log(member.node.name, "port out of range", local_port, "expected to be between 1 and " .. port_offset.range)
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
      if member.attached_colors[dir] then
        local port_offset = DataNetwork.COLOR_RANGE[member.attached_colors[dir]]

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
            yatm_core.table_bury(network.ready_to_receive, {sub_network_id, global_port, member_id, dir}, state)
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
    if member.attached_colors[dir] then
      local port_offset = DataNetwork.COLOR_RANGE[member.attached_colors[dir]]

      if local_port >= 1 and local_port <= port_offset.range then
        local global_port = port_offset.offset + local_port

        local sub_network_id = member.sub_network_ids[dir]

        if sub_network_id then
          yatm_core.table_bury(network.ready_to_receive, {sub_network_id, global_port, member_id, dir}, state)
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

function ic:generate_network_id()
  local result = {}
  for i = 1,4 do
    table.insert(result, yatm_core.random_string32(2))
  end
  return table.concat(result, ":")
end

function ic:_queue_refresh(base_pos, reason)
  self:log("queue_refresh", minetest.pos_to_string(base_pos), reason)
  local hash = minetest.hash_node_position(base_pos)
  self.m_queued_refreshes[hash] = {
    pos = base_pos,
    cancelled = false,
  }
  for dir,v3 in pairs(yatm_core.DIR6_TO_VEC3) do
    local pos = vector.add(base_pos, v3)
    local hash = minetest.hash_node_position(pos)
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
        if yatm_core.is_table_empty(network.members) then
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

function ic:_internal_remove_node(pos, node)
  self:log("unregister_member", minetest.pos_to_string(pos))
  local member_id = minetest.hash_node_position(pos)
  local entry = self.m_members[member_id]
  if entry then
    self:do_unregister_member_groups(entry)

    if entry.block_id then
      if self.m_block_members[entry.block_id] then
        self.m_block_members[entry.block_id][member_id] = nil

        if yatm_core.is_table_empty(self.m_block_members[entry.block_id]) then
          self.m_block_members[entry.block_id] = nil
        end
      end
    end

    self:do_unregister_member_from_networks(entry)

    self.m_members[member_id] = nil
  end
  return self
end

function ic:unload_block(block_id)
  local member_ids = self.m_block_members[block_id]

  if member_ids then
    self.m_block_members[block_id] = nil

    for member_id,_ in pairs(member_ids) do
      local member = self.m_members[member_id]

      if member then
        self:remove_node(member.pos, member.node)
      end
    end
  end
end

function ic:remove_network(network_id)
  -- I hope you weren't expecting something spectacular.
  self.m_networks[network_id] = nil
  return self
end

function ic:handle_network_dispatch(network, dt)
  if not yatm_core.is_table_empty(network.ready_to_send) and
     not yatm_core.is_table_empty(network.ready_to_receive) then

    local old_ready_to_send = network.ready_to_send
    local old_ready_to_receive = network.ready_to_receive

    network.ready_to_send = {}
    network.ready_to_receive = {}

    for sub_network_id, sub_network_ports in pairs(old_ready_to_receive) do
      for port, members in pairs(sub_network_ports) do
        for member_id, dirs in pairs(members) do
          for dir, state in pairs(dirs) do
            if state == "active" then
              yatm_core.table_bury(network.ready_to_receive, {sub_network_id, port, member_id, dir}, state)
            end
          end
        end
      end
    end

    -- yes, this purposely doesn't support multiple members sending on the same port.
    for sub_network_id, sub_network_ports in pairs(old_ready_to_send) do
      local subnet_receivers = old_ready_to_receive[sub_network_id]

      if subnet_receivers then
        for port, members in pairs(sub_network_ports) do
          local port_receivers = subnet_receivers[port]

          if port_receivers then
            for member_id, dirs in pairs(members) do
              for _dir, value in pairs(dirs) do
                for receiver_member_id, receiver_dirs in pairs(port_receivers) do
                  local new_receiver_dirs = {}
                  for receiver_dir, receiver_state in pairs(receiver_dirs) do
                    if receiver_state == "active" then
                      new_receiver_dirs[receiver_dir] = receiver_state
                    else
                      new_receiver_dirs[receiver_dir] = false
                    end
                    local receiver = self.m_members[receiver_member_id]

                    if receiver then
                      local receiver_node = minetest.get_node_or_nil(receiver.pos)

                      if receiver_node then
                        local nodedef = minetest.registered_nodes[receiver_node.name]

                        if nodedef.data_interface then
                          local local_port = self:net_port_to_local_port(port, receiver.attached_colors[receiver_dir])
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
    for member_id,_is_present in pairs(updatable) do
      local member = self.m_members[member_id]
      if member then
        local nodedef = minetest.registered_nodes[member.node.name]
        if nodedef.data_interface then
          local node = minetest.get_node(member.pos)
          nodedef.data_interface:update(member.pos, node, dt)
        else
          self:log("WARN: Node cannot be subject to updatable group without a data_interface",
                minetest.pos_to_string(member.pos), member.node.name)
        end
      else
        self:log("WARN: Network contains invalid member", member_id)
        needs_fix = true
      end
    end

    if needs_fix then
      local new_updatable = {}
      for member_id,value in pairs(updatable) do
        local member = self.m_members[member_id]
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
  local from_dir = yatm_core.facedir_to_local_face(from_node.param2, origin_dir)
  local to_dir = yatm_core.facedir_to_local_face(to_node.param2, origin_dir)

  print(table.concat({
        "FROM", minetest.pos_to_string(from_pos), from_node.name, from_node.param2, from_device.type,
        "TO", minetest.pos_to_string(to_pos), to_node.name, to_node.param2, to_device.type,
        "origin=" .. yatm_core.DIR_TO_STRING[origin_dir],
        "from_local=" .. yatm_core.DIR_TO_STRING[from_dir],
        "to_local=" .. yatm_core.DIR_TO_STRING[to_dir],
        }, " "))
  ]]

  if from_device.type == "mounted_cable" or
     from_device.type == "mounted_bus" then
    local local_dir = yatm_core.facedir_to_local_face(from_node.param2, origin_dir)
    if not from_device.accessible_dirs[local_dir] then
      return false, "originating device is not accessible in direction"
    end
  end

  if to_device.type == "mounted_cable" or
     to_device.type == "mounted_bus" then
    local inverted_dir = yatm_core.invert_dir(origin_dir)
    local local_dir = yatm_core.facedir_to_local_face(to_node.param2, inverted_dir)
    if not to_device.accessible_dirs[local_dir] then
      return false, "target device is not accessible from direction"
    end
  end

  return devices_have_compatible_colors(from_device, to_device)
end

function ic:refresh_from_pos(base_pos)
  --print("refresh_from_pos", minetest.pos_to_string(base_pos))
  local member_id = minetest.hash_node_position(base_pos)
  local member = self.m_members[member_id]
  if member then
    if member.resolution_id == self.m_resolution_id then
      -- no need to refresh, we've already resolved from this position
      return
    end
  end

  local seen = {}
  local found = {}
  local to_check = {base_pos}

  while not yatm_core.is_table_empty(to_check) do
    local old_to_check = to_check
    to_check = {}

    for _, pos in ipairs(old_to_check) do
      local hash = minetest.hash_node_position(pos)

      if not seen[hash] then
        seen[hash] = true

        local node = minetest.get_node(pos)
        local nodedef = minetest.registered_nodes[node.name]

        if nodedef then
          local device = nodedef.data_network_device

          if device then
            found[device.type] = found[device.type] or {}
            found[device.type][hash] = pos

            for dir,_ in pairs(yatm_core.DIR6_TO_VEC3) do
              local v3 = yatm_core.DIR6_TO_VEC3[dir]
              local other_pos = vector.add(pos, v3)
              local other_node = minetest.get_node(other_pos)
              local other_nodedef = minetest.registered_nodes[other_node.name]

              if other_nodedef then
                local other_device = other_nodedef.data_network_device
                if other_device then
                  local valid, err = can_connect_to(pos, node, device, dir,
                                                    other_pos, other_node, other_device)
                  if valid then
                    table.insert(to_check, other_pos)
                  else
                    if err then
                      self:log(minetest.pos_to_string(pos), minetest.pos_to_string(other_pos), err)
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
  local network_id = self:generate_network_id()
  -- make sure we don't already have that network
  -- I mean, what are the chances of that happening?
  while self.m_networks[network_id] do
    network_id = self:generate_network_id()
  end

  local network = {
    id = network_id,
    sub_networks = {},
    members = {},
    members_by_group = {},
    ready_to_send = {},
    ready_to_receive = {},
  }

  for device_type, devices in pairs(found) do
    for member_id, pos in pairs(devices) do
      -- go through the unregistration process, in case the node wasn't already unregistered
      self:_internal_remove_node(pos, nil)

      local member_entry = self.m_members[member_id] or {}

      local node = minetest.get_node(pos)
      local nodedef = minetest.registered_nodes[node.name]
      local dnd = assert(nodedef.data_network_device)

      local block_id = yatm.clusters:mark_node_block(pos, node)

      member_entry.id = member_id
      member_entry.block_id = block_id
      member_entry.pos = member_entry.pos or pos
      member_entry.node = yatm_core.table_copy(node)
      member_entry.type = dnd.type
      member_entry.accessible_dirs = yatm_core.table_copy(dnd.accessible_dirs)
      member_entry.color = dnd.color
      member_entry.groups = dnd.groups or {}
      member_entry.resolution_id = self.m_resolution_id
      member_entry.network_id = network.id
      member_entry.attached_colors = yatm_core.table_copy(member_entry.attached_colors) or {}
      member_entry.sub_network_id = nil
      member_entry.sub_network_ids = {}

      -- Now to re-register it without the register_member function
      -- Since that includes the side effect of causing yet another refresh...
      --
      -- members are indexed by their member_id (i.e the hash)
      self.m_members[member_id] = member_entry

      if not self.m_block_members[block_id] then
        self.m_block_members[block_id] = {}
      end
      self.m_block_members[block_id][member_id] = true

      network.members[member_id] = true
    end
  end

  if not yatm_core.is_table_empty(network.members) then
    self:log("new data network", network.id)
    self.m_networks[network.id] = network

    for member_id, _ in pairs(network.members) do
      local member = self.m_members[member_id]
      self:do_register_member_groups(member)

      if member.type == "device" then
        for dir,v3 in pairs(yatm_core.DIR6_TO_VEC3) do
          local other_pos = vector.add(member.pos, v3)
          local other_hash = minetest.hash_node_position(other_pos)

          if network.members[other_hash] then
            local other_member = self.m_members[other_hash]
            if other_member.type == "bus" or
               other_member.type == "mounted_bus" then
              -- the color is used to determine what port range is usable
              -- this also affects emission
              -- each cable color has a maximum of 16 ports (1-16)
              -- the exception to this rule is the `multi`, which allows 256 (1-256)
              -- when a value is emitted on the network, it is adjusted by its color
              member.attached_colors[dir] = other_member.color
              break
            end
          end
        end
      end

    end

    --
    self:_build_sub_networks(network)

    for member_id, _ in pairs(network.members) do
      local member = self.m_members[member_id]
      local node = minetest.get_node(member.pos)
      local nodedef = minetest.registered_nodes[node.name]

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
  for member_id, _ in pairs(network.members) do
    local member = self.m_members[member_id]

    -- Create subnets by buses
    if member.type == "bus" or
       member.type == "mounted_bus" then
      if not member.sub_network_id then
        self:_build_sub_network(network, member.pos)
      end
    end
  end
end

function ic:_build_sub_network(network, origin_pos)
  local seen = {}

  local explore = {origin_pos}
  local nodes = {}

  while not yatm_core.is_table_empty(explore) do
    local old_explore = explore
    explore = {}

    for _, pos in ipairs(old_explore) do
      local hash = minetest.hash_node_position(pos)

      if not seen[hash] then
        seen[hash] = true
        if network.members[hash] then
          local member = self.m_members[hash]

          if member.type == "bus" or
             member.type == "cable" or
             member.type == "mounted_bus" or
             member.type == "mounted_cable" then
            nodes[hash] = true

            for dir, _ in pairs(yatm_core.DIR6_TO_VEC3) do
              local vec = yatm_core.DIR6_TO_VEC3[dir]
              local other_pos = vector.add(pos, vec)
              local other_hash = minetest.hash_node_position(other_pos)

              if network.members[other_hash] then
                local other_member = self.m_members[other_hash]
                if other_member then
                  if can_connect_to(pos, member.node, member, dir,
                                    other_pos, other_member.node, other_member) then
                    table.insert(explore, other_pos)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  local sub_network_id = self:generate_network_id()
  while network.sub_networks[sub_network_id] do
    sub_network_id = self:generate_network_id()
  end

  network.sub_networks[sub_network_id] = {
    id = sub_network_id,
    cables = nodes,
    devices = {}
  }

  self:log("new sub network", "network_id=" .. network.id, "sub_network_id=" .. sub_network_id)

  local sub_network = network.sub_networks[sub_network_id]

  for member_id, _ in pairs(nodes) do
    local member = self.m_members[member_id]
    member.sub_network_id = sub_network_id

    if member.type == "bus" then
      for dir, vec in pairs(yatm_core.DIR6_TO_VEC3) do
        local pos = vector.add(member.pos, vec)
        local hash = minetest.hash_node_position(pos)

        if network.members[hash] then
          local other_member = self.m_members[hash]
          if other_member and other_member.type == "device" then
            sub_network.devices[hash] = true
            local new_dir = yatm_core.invert_dir(dir)
            other_member.attached_colors[new_dir] = member.color
            other_member.sub_network_ids[new_dir] = sub_network_id
          end
        end
      end
    elseif member.type == "mounted_bus" then
      for origin_dir, _ in pairs(member.accessible_dirs) do
        local dir = yatm_core.facedir_to_face(member.node.param2, origin_dir)
        local vec = yatm_core.DIR6_TO_VEC3[dir]
        local pos = vector.add(member.pos, vec)
        local hash = minetest.hash_node_position(pos)

        if network.members[hash] then
          local other_member = self.m_members[hash]
          if other_member and other_member.type == "device" then
            sub_network.devices[hash] = true
            local inverted_dir = yatm_core.invert_dir(dir)
            other_member.attached_colors[inverted_dir] = member.color
            other_member.sub_network_ids[inverted_dir] = sub_network_id
          end
        end
      end
    end
  end
end

local data_network = DataNetwork:new()

do
  minetest.register_on_mods_loaded(data_network:method("init"))
  minetest.register_globalstep(data_network:method("update"))
  minetest.register_on_shutdown(data_network:method("terminate"))

  minetest.register_lbm({
    name = "yatm_data_network:data_network_reload_lbm",
    nodenames = {
      "group:yatm_data_device",
      "group:data_cable",
      "group:data_cable_bus",
    },
    run_at_every_load = true,
    action = function (pos, node)
      data_network:upsert_member(pos, node)
      local nodedef = minetest.registered_nodes[node.name]

      if nodedef then
        if nodedef.data_interface then
          nodedef.data_interface:on_load(pos, node)
        end
      end
    end
  })
end

yatm_data_network.DataNetwork = DataNetwork
yatm_data_network.data_network = data_network
