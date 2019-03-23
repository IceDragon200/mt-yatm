local SpacetimeMeta = assert(yatm_spacetime.SpacetimeMeta)

local SpacetimeNetwork = yatm_core.Class:extends()

local m = assert(SpacetimeNetwork.instance_class)

function m:initialize(description)
  self.m_description = description
  self.m_members = {}
  self.m_members_by_address = {}
  self.m_members_by_group = {}
end

function m:register_device(groups, pos, address)
  assert(groups, "expected groups")
  assert(pos, "expected a valid position")
  assert(address, "expected a valid address")
  print(self.m_description, "register_device/3", dump(groups), minetest.pos_to_string(pos), address)
  local hash = minetest.hash_node_position(pos)

  if self.m_members[hash] then
    error("multiple registrations detected, did you mean to use `update_device/2`?" .. minetest.pos_to_string(pos))
  else
    self.m_members[hash] = {
      pos = pos,
      address = address,
      groups = groups,
    }
    for group_name,_ in pairs(self.m_members[hash].groups) do
      self.m_members_by_group[group_name] = self.m_members_by_group[group_name] or {}
      local group_members = self.m_members_by_group[group_name]
      group_members[hash] = true
    end
    self.m_members_by_address[address] = self.m_members_by_address[address] or {}
    self.m_members_by_address[address][hash] = true
    return true
  end
end

function m:update_device(groups, pos, new_address)
  assert(pos, "expected a valid position")
  print(self.m_description, "update_device/3", dump(groups), minetest.pos_to_string(pos), dump(new_address))
  local hash = minetest.hash_node_position(pos)
  if self.m_members[hash] then
    self:unregister_device(pos)
  end
  if new_address then
    return self:register_device(groups, pos, new_address)
  else
    return false
  end
end

function m:maybe_register_node(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos)
    local address = yatm_spacetime.SpacetimeMeta.get_address(meta)
    local spacetime_groups = assert(nodedef.yatm_spacetime).groups or {}
    if not yatm_core.is_blank(address) then
      return self:register_device(spacetime_groups, pos, address)
    else
      return false
    end
  else
    error("No such node " .. node.name)
  end
end

function m:maybe_update_node(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos)
    local address = yatm_spacetime.SpacetimeMeta.get_address(meta)
    local spacetime_groups = assert(nodedef.yatm_spacetime).groups or {}
    return self:update_device(spacetime_groups, pos, address)
  else
    error("No such node " .. node.name)
  end
end

function m:unregister_device(pos)
  assert(pos, "expected a valid position")
  print("unregister_device/2", minetest.pos_to_string(pos))
  local hash = minetest.hash_node_position(pos)

  local entry = self.m_members[hash]
  self.m_members[hash] = nil

  if entry then
    if self.m_members_by_address[entry.address] then
      self.m_members_by_address[entry.address][hash] = nil
      if yatm_core.is_table_empty(self.m_members_by_address[entry.address]) then
        self.m_members_by_address[entry.address] = nil
      end
    end

    for group_name,_ in pairs(entry.groups) do
      if self.m_members_by_group[group_name] then
        self.m_members_by_group[group_name][hash] = nil
        if yatm_core.is_table_empty(self.m_members_by_group[group_name]) then
          self.m_members_by_group[group_name] = nil
        end
      end
    end

    return true
  else
    return false
  end
end

function m:each_member_in_group_by_address(group_name, address, callback)
  if self.m_members_by_address[address] then
    if self.m_members_by_group[group_name] then
      local group_members = self.m_members_by_group[group_name]
      for hash,_ in pairs(self.m_members_by_address[address]) do
        if group_members[hash] then
          if not callback(hash, self.m_members[hash]) then
            break
          end
        end
      end
    end
  end
end

function m:on_shutdown()
  print("yatm_spacetime.Network.on_shutdown/0", "Shutting down")
end

yatm_spacetime.SpacetimeNetwork = SpacetimeNetwork
yatm_spacetime.Network = SpacetimeNetwork:new()

minetest.register_on_shutdown(function ()
  yatm_spacetime.Network.on_shutdown()
end)


