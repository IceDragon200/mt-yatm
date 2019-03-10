local Network = {
  members = {},
  members_by_address = {},
}

function Network.register_device(pos, address)
  assert(pos, "expected a valid position")
  assert(address, "expected a valid address")
  print("yatm_spacetime.Network.register_device/2", minetest.pos_to_string(pos), address)
  local hash = minetest.hash_node_position(pos)

  Network.members[hash] = address
  Network.members_by_address[address] = Network.members_by_address[address] or {}
  Network.members_by_address[address][hash] = pos
end

function Network.unregister_device(pos)
  assert(pos, "expected a valid position")
  print("yatm_spacetime.Network.unregister_device/2", minetest.pos_to_string(pos))
  local hash = minetest.hash_node_position(pos)

  local address = Network.members[hash]
  Network.members[hash] = nil

  if address and Network.members_by_address[address] then
    Network.members_by_address[address][hash] = nil

    if yatm_core.is_table_empty(Network.members_by_address[address]) then
      Network.members_by_address[address] = nil
    end
  end
end

function Network.poses_for_address(address)
  return Network.members_by_address[address]
end

--[[
Retrieve a position for the given address, that isn't the given position.

Since spacetime devices are normally paired, they will appear under the same address.
]]
function Network.pos_for_address_from_pos(address, pos)
  local target_poses = Network.poses_for_address(address)
  local target_pos = nil
  if target_poses then
    local hash = minetest.hash_node_position(pos)
    for new_hash,new_pos in pairs(target_poses) do
      if new_hash ~= hash then
        target_pos = new_pos
        break
      end
    end
  else
    print("no target_poses")
  end
  return target_pos
end

function Network.on_shutdown()
  print("yatm_spacetime.Network.on_shutdown/0", "Shutting down")
end

minetest.register_on_shutdown(Network.on_shutdown)

yatm_spacetime.Network = Network

