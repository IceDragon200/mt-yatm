local is_blank = assert(foundation.com.is_blank)
local is_table_empty = assert(foundation.com.is_table_empty)

local SpacetimeMeta = assert(yatm_spacetime.SpacetimeMeta)

local SpacetimeNetwork = foundation.com.Class:extends("SpacetimeNetwork")
local ic = SpacetimeNetwork.instance_class

function ic:initialize(description)
  self.m_description = description
  self.m_members = {}
  self.m_members_by_address = {}
  self.m_members_by_group = {}
  self.m_members_by_block = {}

  yatm.clusters:observe('on_block_expired',
                        'yatm_spacetime_network/block_unloader', function (block_id)
    self:unload_block(block_id)
  end)
end

function ic:register_device(groups, pos, address)
  assert(groups, "expected groups")
  assert(pos, "expected a valid position")
  assert(address, "expected a valid address")
  print(self.m_description, "register_device/3", dump(groups), minetest.pos_to_string(pos), address)
  local member_id = minetest.hash_node_position(pos)

  if self.m_members[member_id] then
    error("multiple registrations detected, did you mean to use `update_device/2`?" ..
          minetest.pos_to_string(pos))
  else
    local node = minetest.get_node(pos)
    local block_id = yatm.clusters:mark_node_block(pos, node)

    self.m_members[member_id] = {
      id = member_id,
      block_id = block_id,
      pos = pos,
      address = address,
      groups = groups,
    }

    for group_name,_ in pairs(self.m_members[member_id].groups) do
      self.m_members_by_group[group_name] = self.m_members_by_group[group_name] or {}
      local group_members = self.m_members_by_group[group_name]
      group_members[member_id] = true
    end

    if not self.m_members_by_address[address] then
      self.m_members_by_address[address] = {}
    end
    self.m_members_by_address[address][member_id] = true

    if not self.m_members_by_block[block_id] then
      self.m_members_by_block[block_id] = {}
    end
    self.m_members_by_block[block_id][member_id] = true
    return true
  end
end

function ic:update_device(groups, pos, new_address)
  assert(pos, "expected a valid position")
  print(self.m_description, "update_device/3", dump(groups),
        minetest.pos_to_string(pos), dump(new_address))
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

function ic:maybe_register_node(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos)
    local address = SpacetimeMeta.get_address(meta)
    if nodedef.yatm_spacetime then
      local spacetime_groups = nodedef.yatm_spacetime.groups or {}
      if not is_blank(address) then
        return self:register_device(spacetime_groups, pos, address)
      else
        return false
      end
    else
      error("expected node " .. node.name .. " to have a yatm_spacetime")
    end
  else
    error("No such node " .. node.name)
  end
end

function ic:maybe_update_node(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local meta = minetest.get_meta(pos)
    local address = SpacetimeMeta.get_address(meta)
    if nodedef.yatm_spacetime then
      local spacetime_groups = nodedef.yatm_spacetime.groups or {}
      return self:update_device(spacetime_groups, pos, address)
    else
      error("expected node " .. node.name .. " to have a yatm_spacetime")
    end
  else
    error("No such node " .. node.name)
  end
end

function ic:unregister_device(pos)
  assert(pos, "expected a valid position")
  print("unregister_device/2", minetest.pos_to_string(pos))

  local member_id = minetest.hash_node_position(pos)

  local entry = self.m_members[member_id]
  self.m_members[member_id] = nil

  if entry then
    if self.m_members_by_block[entry.block_id] then
      self.m_members_by_block[entry.block_id][member_id] = nil
      if is_table_empty(self.m_members_by_block[entry.block_id]) then
        self.m_members_by_block[entry.block_id] = nil
      end
    end

    if self.m_members_by_address[entry.address] then
      self.m_members_by_address[entry.address][member_id] = nil
      if is_table_empty(self.m_members_by_address[entry.address]) then
        self.m_members_by_address[entry.address] = nil
      end
    end

    for group_name,_ in pairs(entry.groups) do
      if self.m_members_by_group[group_name] then
        self.m_members_by_group[group_name][member_id] = nil
        if is_table_empty(self.m_members_by_group[group_name]) then
          self.m_members_by_group[group_name] = nil
        end
      end
    end

    return true
  else
    return false
  end
end

function ic:each_member_in_group_by_address(group_name, address, callback)
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

function ic:unload_block(block_id)
  local block_members = self.m_members_by_block[block_id]
  if block_members then
    self.m_members_by_block[block_id] = nil

    for member_id,_ in pairs(block_members) do
      local member = self.m_members[member_id]
      self:unregister_device(member.pos)
    end
  end
end

function ic:terminate()
  print("yatm_spacetime.network", "terminating")
  print("yatm_spacetime.network", "terminated")
end

yatm_spacetime.SpacetimeNetwork = SpacetimeNetwork
yatm_spacetime.network = SpacetimeNetwork:new("yatm.spacetime.network")

minetest.register_on_shutdown(yatm_spacetime.network:method("terminate"))
