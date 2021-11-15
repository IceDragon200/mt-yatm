--[[
"This looks familiar", I hear you mumble, of it is, it's a copy of the yatm_spacetime network.

But this one is used specifically for the wireless components of mesecon_hubs.

In addition it also has an update step.
]]
local NetworkMeta = assert(yatm_mesecon_hubs.NetworkMeta)
local is_table_empty = assert(foundation.com.is_table_empty)
local is_blank = assert(foundation.com.is_blank)
local Trace = assert(foundation.com.Trace)

local WirelessNetwork = foundation.com.Class:extends("WirelessNetwork")
local ic = WirelessNetwork.instance_class

function ic:initialize()
  self.m_members = {}
  self.m_members_by_address = {}

  self.m_queue = {}

  self.m_counter = 0
end

function ic:register_listener(pos, address)
  assert(pos, "expected a valid position")
  assert(address, "expected a valid address")
  print("yatm_mesecon_hubs.wireless_network", "register_listener/2", minetest.pos_to_string(pos), address)
  local hash = minetest.hash_node_position(pos)

  self.m_members[hash] = address
  self.m_members_by_address[address] = self.m_members_by_address[address] or {}
  self.m_members_by_address[address][hash] = pos
end

function ic:unregister_listener(pos)
  assert(pos, "expected a valid position")
  print("yatm_mesecon_hubs.wireless_network", "unregister_listener/2", minetest.pos_to_string(pos))
  local hash = minetest.hash_node_position(pos)

  local address = self.m_members[hash]
  self.m_members[hash] = nil

  if address and self.m_members_by_address[address] then
    self.m_members_by_address[address][hash] = nil

    -- Check if there are no more members in the members_by_address map
    if is_table_empty(self.m_members_by_address[address]) then
      self.m_members_by_address[address] = nil
    end
  end
end

function ic:emit_value(from_pos, to_address, value)
  assert(from_pos, "expected an origin position")
  assert(to_address, "expected a target address")
  assert(value, "expected a value")
  --print("emit_value/3", minetest.pos_to_string(from_pos), dump(to_address), dump(value))
  self.m_queue[to_address] = { pos = from_pos, value = value }
end

function ic:dispatch_queued()
  local had_queued = false
  for address,event in pairs(self.m_queue) do
    had_queued = true

    if self.m_members_by_address[address] then
      for _hash,pos in pairs(self.m_members_by_address[address]) do
        local node = minetest.get_node(pos)
        if node then
          local nodedef = minetest.registered_nodes[node.name]

          if nodedef and nodedef.mesecons_wireless_device then
            local mwd = nodedef.mesecons_wireless_device

            if mwd.action_pdu then
              --print("Triggering action_pdu/3", minetest.pos_to_string(pos), node.name, dump(event))
              mwd.action_pdu(pos, node, event)
            else
              print("Device at", minetest.pos_to_string(pos), "does not define action_pdu/3")
            end
          else
            print("Device at", minetest.pos_to_string(pos), "was registered but does not define mesecons_wireless_device")
          end
        end
      end
    end
  end
  if had_queued then
    self.m_queue = {}
  end
end

function ic:update(dtime, trace)
  local counter = self.m_counter

  local span = span:span_start("dispatch_queued/0")
  self:dispatch_queued()
  span:span_end()
  --Trace.inspect(ot)

  self.m_counter = counter + 1
end

function ic:terminate()
  print("yatm_mesecon_hubs.wireless_network", "terminate/0", "terminating")
  print("yatm_mesecon_hubs.wireless_network", "terminate/0", "terminated")
end

local wireless_network = WirelessNetwork:new()

nokore_proxy.register_globalstep(
  "yatm_mesecon_hubs.update/1",
  wireless_network:method("update")
)
minetest.register_on_shutdown(wireless_network:method("terminate"))

minetest.register_lbm({
  name = "yatm_mesecon_hubs:listening_hub_device_reregister",
  nodenames = {
    "group:listening_hub_device",
  },
  run_at_every_load = true,
  action = function (pos, node)
    local meta = minetest.get_meta(pos)
    local address = NetworkMeta.get_hub_address(meta)
    if not is_blank(address) then
      wireless_network:register_listener(pos, address)
    end
  end,
})

yatm_mesecon_hubs.WirelessNetwork = WirelessNetwork
yatm_mesecon_hubs.wireless_network = wireless_network
