--
--
--
local DataNetwork = yatm_core.Class:extends()
local ic = assert(DataNetwork.instance_class)

DataNetwork.PORT_RANGE = 16
DataNetwork.COLOR_RANGE = {
-- name      = {offset :: integer, range :: integer}
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
  self.m_queued_refreshes = {}
  self.m_networks = {}
  self.m_members = {}
  self.m_members_by_group = {}
  self.m_block_members = {}
  self.m_resolution_id = 0

  yatm.clusters:observe('on_block_expired', 'yatm_data_network/block_unloader', function (block_id)
    self:unload_block(block_id)
  end)
end

function ic:get_port_offset_for_color(color)
  return DataNetwork.COLOR_RANGE[color].offset
end

function ic:get_port_range_for_color(color)
  return DataNetwork.COLOR_RANGE[color].range
end

function ic:local_port_to_net_port(local_port, color)
  return self:get_port_offset_for_color(color) + local_port
end

function ic:net_port_to_local_port(net_port, color)
  return net_port - self:get_port_offset_for_color(color)
end

function ic:generate_network_id()
  local result = {self.m_abbr}
  for i = 1,4 do
    table.insert(result, yatm_core.random_string16(4))
  end
  return table.concat(result, ":")
end

function ic:queue_refresh(base_pos)
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

function ic:queue_cancel_refresh(pos)
  local hash = minetest.hash_node_position(pos)
  local entry = self.m_queued_refreshes[hash]
  if entry then
    entry.cancelled = true
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
    print("DataNetwork", "do_register_member_groups", "registering to group", member.id, group)
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

function ic:do_unregister_network_member(member)
  local network = self.m_networks[member.network_id]
  if network then
    network.members[member.id] = nil
    if yatm_core.is_table_empty(network.members) then
      self:remove_network(member.network_id)
    end
  end
  return self
end

-- @spec add_node(Vector3.t, Node.t) :: DataNetwork.t
function ic:add_node(pos, node)
  print("DataNetwork", "add_node", minetest.pos_to_string(pos), node.name)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    error("cannot register " .. minetest.pos_to_string(pos) .. " " .. node.name .. " it was already registered by " .. member.node.name)
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
    attached_color = nil,
    port_values = {}
  }

  local block_id = yatm.clusters:mark_node_block(member.pos, member.node)
  if not self.m_block_members[block_id] then
    self.m_block_members[block_id] = {}
  end
  self.m_block_members[block_id][member_id] = true
  member.block_id = block_id
  self.m_members[member_id] = member

  self:do_register_member_groups(member)
  self:queue_refresh(pos)
  return self
end

-- @spec update_member(Vector3.t, Node.t) :: DataNetwork.t
function ic:update_member(pos, node)
  print("DataNetwork", "update_member", minetest.pos_to_string(pos), node.name)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    member.node = node
    self:do_unregister_member_groups(member)

    local nodedef = minetest.registered_nodes[node.name]
    local dnd = assert(nodedef.data_network_device)
    member.groups = dnd.groups or {}
    self:do_register_member_groups(member)
    yatm.clusters:mark_node_block(member.pos, member.node)
  else
    error("no such member " .. minetest.pos_to_string(pos))
  end
  return self
end

function ic:upsert_member(pos, node)
  print("DataNetwork", "upsert_member", minetest.pos_to_string(pos), node.name)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    return self:update_member(pos, node)
  else
    return self:add_node(pos, node)
  end
end

-- @spec unregister_member(Vector3.t, Node.t | nil) :: DataNetwork.t
function ic:unregister_member(pos, node)
  print("DataNetwork", "unregister_member", minetest.pos_to_string(pos))
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    self:do_unregister_member_groups(member)
    if member.network_id then
      self:do_unregister_network_member(member)
    end
    if member.block_id then
      if self.m_block_members[member.block_id] then
        self.m_block_members[member.block_id][member_id] = nil

        if is_table_empty(self.m_block_members[member.block_id]) then
          self.m_block_members[member.block_id] = nil
        end
      end
    end
    self.m_members[member_id] = nil
    self:queue_refresh(pos)
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
        self:unregister_member(member.pos, member.node)
      end
    end
  end
end

function ic:remove_network(network_id)
  -- I hope you weren't expecting something spectacular.
  self.m_members[network_id] = nil
  return self
end

function ic:send_value_to_network(network_id, member_id, local_port, value)
  local network = self.m_networks[network_id]
  if network then
    local member = self.m_members[member_id]
    if member.attached_color then
      local port_offset = DataNetwork.COLOR_RANGE[member.attached_color]
      if local_port >= 1 and local_port <= port_offset.range then
        local global_port = port_offset.offset + local_port
        member.port_values[global_port] = value
        network.ready_to_send[global_port] = member_id
      else
        print("ERR: ", member.node.name, "port out of range", local_port, "expected to be between 1 and " .. port_offset.range)
      end
    else
      --print("WARN: ", member.node.name, "does not have an attached color; cannot send")
    end
  end
  return self
end

-- Call this from a node to emit a value unto it's network on a specified port
-- You can emit on any port, doesn't mean anyone will receive your value.
function ic:send_value(pos, node, port, value)
  --print("send_value", minetest.pos_to_string(pos), node.name, port, value)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member and member.network_id then
    self:send_value_to_network(member.network_id, member_id, port, value)
  end
  return self
end

function ic:mark_ready_to_receive_in_network(network_id, member_id, local_port)
  local network = self.m_networks[network_id]
  if network then
    local member = self.m_members[member_id]
    if member.attached_color then
      local port_offset = DataNetwork.COLOR_RANGE[member.attached_color]

      if local_port >= 1 and local_port <= port_offset.range then
        local port = port_offset.offset + local_port
        network.ready_to_receive[port] = network.ready_to_receive[port] or {}
        network.ready_to_receive[port][member_id] = true
      else
        print("ERR: ", member.node.name, "port out of range", local_port, "expected to be between 1 and " .. port_offset.range)
      end
    else
      --print("WARN: ", member.node.name, "does not have an attached color; cannot be readied for receive")
    end
  end
  return self
end

function ic:mark_ready_to_receive(pos, port)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member and member.network_id then
    self:mark_ready_to_receive_in_network(member.network_id, member_id, port)
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

function ic:get_attached_color(pos)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    return member.attached_color
  end
  return nil
end

function ic:update_network(network, dt)
  -- Need both senders and receivers
  if not yatm_core.is_table_empty(network.ready_to_send) and
     not yatm_core.is_table_empty(network.ready_to_receive) then
    -- yes, this purposely doesn't support multiple members sending on the same port.
    for port, member_id in pairs(network.ready_to_send) do
      local sender = self.m_members[member_id]
      local receivers = network.ready_to_receive[port]
      local local_port = self:net_port_to_local_port(port, sender.attached_color)
      if receivers then
        local value = sender.port_values[port]
        for member_id, _ in pairs(receivers) do
          local receiver = self.m_members[member_id]

          local receiver_node = minetest.get_node(receiver.pos)
          if receiver_node.name ~= "ignore" then
            local nodedef = minetest.registered_nodes[receiver_node.name]

            if nodedef.data_interface then
              nodedef.data_interface.receive_pdu(receiver.pos,
                                                 receiver_node,
                                                 local_port,
                                                 value)
            else
              print("WARN: ", receiver_node.name, "does not have a data interface")
            end
          end
        end
      end
      sender.port_values[port] = nil
    end

    network.ready_to_send = {}
    network.ready_to_receive = {}
  end

  local updatable = network.members_by_group["updatable"]
  if updatable then
    local needs_fix = false
    for member_id,_is_present in pairs(updatable) do
      local member = self.m_members[member_id]
      if member then
        local nodedef = minetest.registered_nodes[member.node.name]
        if nodedef.data_interface then
          nodedef.data_interface.update(member.pos, member.node, dt)
        else
          print("WARN: Node cannot be subject to updatable group without a data_interface",
                minetest.pos_to_string(member.pos), member.node.name)
        end
      else
        print("WARN: Network contains invalid member", member_id)
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

local function can_connect_to_device(from_device, to_device)
  if from_device.type == "cable" then
    -- cables can only connect to other cables or buses
    -- and they can only connect to those of the same color or a 'multi'
    if to_device.type == "cable" or to_device.type == "bus" then
      return compatible_colors(from_device.color, to_device.color)
    end
  elseif from_device.type == "bus" then
    -- buses can connect to cables of the same color, multi or a device
    if to_device.type == "device" then
      return true
    elseif to_device.type == "cable" then
      return compatible_colors(from_device.color, to_device.color)
    end
  end
  return false
end

function ic:refresh_from_pos(base_pos)
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
  local to_check = {}
  to_check[member_id] = base_pos

  while not yatm_core.is_table_empty(to_check) do
    local old_to_check = to_check
    to_check = {}

    for hash, pos in pairs(old_to_check) do
      if not seen[hash] then
        seen[hash] = true
        local node = minetest.get_node(pos)
        local nodedef = minetest.registered_nodes[node.name]

        if nodedef then
          local device = nodedef.data_network_device

          if device then
            found[device.type] = found[device.type] or {}
            found[device.type][hash] = pos

            if device.type == "cable" or device.type == "bus" then
              for dir,v3 in pairs(yatm_core.DIR6_TO_VEC3) do
                local other_pos = vector.add(pos, v3)
                local other_hash = minetest.hash_node_position(other_pos)
                local other_node = minetest.get_node(other_pos)
                local other_nodedef = minetest.registered_nodes[other_node.name]

                if other_nodedef then
                  local other_device = other_nodedef.data_network_device
                  if other_device then
                    if can_connect_to_device(device, other_device) then
                      to_check[other_hash] = other_pos
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
    members = {},
    members_by_group = {},
    ready_to_send = {},
    ready_to_receive = {},
  }

  for device_type, devices in pairs(found) do
    for member_id, pos in pairs(devices) do
      -- go through the unregistration process, in case the node wasn't already unregistered
      self:unregister_member(pos, nil)

      local node = minetest.get_node(pos)
      local nodedef = minetest.registered_nodes[node.name]
      local dnd = assert(nodedef.data_network_device)

      local block_id = yatm.clusters:mark_node_block(pos, node)

      -- Now to re-register it without the register_member function
      -- Since that includes the side effect of causing yet another refresh...
      --
      -- members are indexed by their member_id (i.e the hash)
      self.m_members[member_id] = {
        id = member_id,
        block_id = block_id,
        pos = pos,
        node = node,
        type = dnd.type,
        color = dnd.color,
        groups = dnd.groups or {},
        resolution_id = self.m_resolution_id,
        network_id = network_id,
        port_values = {},
      }

      if not self.m_block_members[block_id] then
        self.m_block_members[block_id] = {}
      end
      self.m_block_members[block_id][member_id] = true

      network.members[member_id] = true
    end
  end

  if not yatm_core.is_table_empty(network.members) then
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
            if other_member.type == "bus" then
              -- the color is used to determine what port range is usable
              -- this also affects emission
              -- each cable color has a maximum of 16 ports (1-16)
              -- the exception to this rule is the `multi`, which allows 256 (1-256)
              -- when a value is emitted on the network, it is adjusted by it's color
              member.attached_color = other_member.color
              break
            end
          end
        end
      end

      yatm.queue_refresh_infotext(member.pos, member.node)
    end
  end
end

function ic:update(dt)
  for network_id, network in pairs(self.m_networks) do
    self:update_network(network, dt)
  end

  if not yatm_core.is_table_empty(self.m_queued_refreshes) then
    print("DataNetwork", "Starting Queued refreshes")
    self.m_resolution_id = self.m_resolution_id + 1
    for hash, t in pairs(self.m_queued_refreshes) do
      if not t.cancelled then
        self:refresh_from_pos(t.pos)
      end
    end
    self.m_queued_refreshes = {}
  end
end

function ic:terminate()
  --
  print("yatm.data_network", "terminating")
  -- release everything
  self.m_queued_refreshes = {}
  self.m_networks = {}
  self.m_members = {}
  self.m_members_by_group = {}
  print("yatm.data_network", "terminated")
end

function ic:get_infotext(pos)
  local network_id = self:get_network_id(pos) or "NULL"
  local color = self:get_attached_color(pos)

  if color then
    return "Data Network: " ..
      network_id ..
      " (" .. color .. ") " ..
      " (" .. self:get_port_offset_for_color(color) .. "/" .. self:get_port_range_for_color(color) .. ")"
  else
    return "Data Network: " .. network_id
  end
end

local data_network = DataNetwork:new()

do
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
    end
  })
end

yatm_data_network.DataNetwork = DataNetwork
yatm_data_network.data_network = data_network
