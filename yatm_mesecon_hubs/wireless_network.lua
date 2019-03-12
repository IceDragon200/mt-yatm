--[[
"This looks familiar", I hear you mumble, of it is, it's a copy of the yatm_spacetime network.

But this one is used specifically for the wireless components of mesecon_hubs.

In addition it also has an update step.
]]
local Network = {
  m_members = {},
  m_members_by_address = {},

  m_queue = {},

  m_counter = 0,
}

function Network.register_listener(pos, address)
  assert(pos, "expected a valid position")
  assert(address, "expected a valid address")
  print("yatm_mesecon_hubs.Network.register_listener/2", minetest.pos_to_string(pos), address)
  local hash = minetest.hash_node_position(pos)

  Network.m_members[hash] = address
  Network.m_members_by_address[address] = Network.m_members_by_address[address] or {}
  Network.m_members_by_address[address][hash] = pos
end

function Network.unregister_listener(pos)
  assert(pos, "expected a valid position")
  print("yatm_mesecon_hubs.Network.unregister_listener/2", minetest.pos_to_string(pos))
  local hash = minetest.hash_node_position(pos)

  local address = Network.m_members[hash]
  Network.m_members[hash] = nil

  if address and Network.m_members_by_address[address] then
    Network.m_members_by_address[address][hash] = nil

    -- Check if there are no more members in the members_by_address map
    if yatm_core.is_table_empty(Network.m_members_by_address[address]) then
      Network.m_members_by_address[address] = nil
    end
  end
end

function Network.emit_value(from_pos, to_address, value)
  Network.m_queue[to_address] = { pos = from_pos, value = value }
end

function Network.dispatch_queued()
  local had_queued = false
  for address,value in pairs(Network.m_queue) do
    had_queued = true

    if Network.m_members_by_address[address] then
      for _hash,pos in pairs(Network.m_members_by_address[address]) do
        local node = minetest.get_node(pos)
        if node then
          local nodedef = minetest.registered_nodes[node.name]

          if nodedef and nodedef.mesecons_wireless_device then
            local mwd = nodedef.mesecons_wireless_device

            if mwd.action_pdu then
              mwd.action_pdu(pos, node, value)
            end
          end
        end
      end
    end
  end
  if had_queued then
    Network.m_queue = {}
  end
end

function Network.update(dtime)
  local counter = Network.m_counter

  local ot = yatm_core.trace.new("yatm_mesecon_hubs.Network.update/1")
  Network.dispatch_queued()
  yatm_core.trace.span_end(ot)

  Network.m_counter = counter + 1
end

function Network.on_shutdown()
  print("yatm_mesecon_hubs.Network.on_shutdown/0", "Shutting down")
end

minetest.register_globalstep(Network.update)
minetest.register_on_shutdown(Network.on_shutdown)

yatm_mesecon_hubs.Network = Network

