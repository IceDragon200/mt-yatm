--
--
--
local DataNetwork = yatm_core.Class:extends()
local ic = assert(DataNetwork.instance_class)

function ic:initialize()
  self.m_queued_refreshes = {}
  self.m_networks = {}
  self.m_members = {}
  self.m_members_by_group = {}
  self.m_resolution_id = 0
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
      self.m_members_by_group[group][member_id] = nil
    end
  end
  return self
end

function ic:do_register_member_groups(member)
  for group, _priority in pairs(member.groups) do
    self.m_members_by_group[group] = self.m_members_by_group[group] or {}
    self.m_members_by_group[group][member_id] = true
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

-- @spec register_member(Vector3.t, Node.t) :: DataNetwork.t
function ic:register_member(pos, node)
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
    groups = dnd.groups or {}
  }

  self.m_members[member_id] = member
  self:do_register_member_groups(member)
  self:queue_refresh(pos)
  return self
end

-- @spec update_member(Vector3.t, Node.t) :: DataNetwork.t
function ic:update_member(pos, node)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    member.node = node
    self:do_unregister_member_groups(member)

    local dnd = assert(nodedef.data_network_device)
    member.groups = dnd.groups or {}
    self:do_register_member_groups(member)
  else
    error("no such member " .. minetest.pos_to_string(pos))
  end
  return self
end

-- @spec unregister_member(Vector3.t, Node.t | nil) :: DataNetwork.t
function ic:unregister_member(pos, node)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member then
    self:do_unregister_member_groups(member)
    if member.network_id then
      self:do_unregister_network_member(member)
    end
    self.m_members[member_id] = nil
    self:queue_refresh(pos)
  end
  return self
end

function ic:remove_network(network_id)
  -- I hope you weren't expecting something spectacular.
  self.m_members[network_id] = nil
  return self
end

function ic:send_value_to_network(network_id, member_id, port, value)
  local network = self.m_networks[network_id]
  if network then
    self.m_members[member_id].last_value = value
    network.ready_to_send[port] = member_id
  end
  return self
end

-- Call this from a node to emit a value unto it's network on a specified port
-- You can emit on any port, doesn't mean anyone will receive your value.
function ic:send_value(pos, port, value)
  local member_id = minetest.hash_node_position(pos)
  local member = self.m_members[member_id]
  if member and member.network_id then
    self:send_value_to_network(member.network_id, member_id, port, value)
  end
  return self
end

function ic:mark_ready_to_receive_in_network(network_id, member_id, port)
  local network = self.m_networks[network_id]
  if network then
    network.ready_to_receive[port] = network.ready_to_receive[port] or {}
    network.ready_to_receive[port][member_id] = true
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

function ic:update_network(network)
  -- Need both senders and receivers
  if not yatm_core.is_table_empty(network.ready_to_send) and not yatm_core.is_table_empty(network.ready_to_receive) then
    -- yes, this purposely doesn't support multiple members sending on the same port.
    for port, member_id in pairs(network.ready_to_send) do
      local sender = self.m_members[member_id]
      local receivers = network.ready_to_receive[port]
      if receivers then
        for member_id, _ in pairs(receivers) do
          local receiver = self.m_members[member_id]

          local receiver_node = minetest.get_node(receiver.pos)
          if receiver_node.name ~= "ignore" then
            local nodedef = minetest.registered_nodes[receiver_node.name]

            if nodedef.data_interface then
              nodedef.data_interface.receive_pdu(receiver.pos, receiver_node, port, sender.last_value)
            else
              print("WARN: ", receiver_node.name, "does not have a data interface")
            end
          end
        end
      end
      sender.last_value = nil
    end

    network.ready_to_send = {}
    network.ready_to_receive = {}
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
                local other_nodedef =  minetest.registered_nodes[other_node.name]

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

      -- Now to re-register it without the register_member function
      -- Since that includes the side effect of causing yet another refresh...
      --
      -- members are indexed by their member_id (i.e the hash)
      self.m_members[member_id] = {
        id = member_id,
        pos = pos,
        node = node,
        groups = dnd.groups or {},
        resolution_id = self.m_resolution_id,
        network_id = network_id,
      }

      network.members[member_id] = true

      -- ya know, I'm not too 100% on this actually...
      yatm_core.queue_refresh_infotext(pos)
    end
  end

  if not yatm_core.is_table_empty(network.members) then
    self.m_networks[network.id] = network
  end
end

function ic:update(dt)
  for network_id, network in pairs(self.m_networks) do
    self:update_network(network)
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
  print("DataNetwork", "terminating")
end

local data_network = DataNetwork:new()

do
  minetest.register_globalstep(function (delta)
    data_network:update(delta)
  end)

  minetest.register_on_shutdown(function ()
    data_network:terminate()
  end)

  minetest.register_lbm({
    name = "yatm_data_network:data_network_reload_lbm",
    nodenames = {
      "group:data_network_device",
      "group:data_cable",
      "group:data_cable_bus",
    },
    run_at_every_load = true,
    action = function (pos, node)
      data_network:register_member(pos, node)
    end
  })
end

yatm_data_network.DataNetwork = DataNetwork
yatm_data_network.data_network = data_network
