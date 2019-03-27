--[[
This Network handles Item Transport, devices can still handle their own item handling.

Only item ducts should register on this network.

The 3 main components of an item transport are:
* Inserters - these will insert items from the network and place them into their adjacent devices
* Extractors - these will extract items from adjacent devices for consumption by the network
* Transporters - these only act as a pathway for the network and only matter when tracing the path
]]
local GenericTransportNetwork = assert(yatm.transport.GenericTransportNetwork)
local DIR6_TO_VEC3 = assert(yatm_core.DIR6_TO_VEC3)
local invert_dir = assert(yatm_core.invert_dir)

local ItemTransportNetwork = GenericTransportNetwork:extends()
local m = assert(ItemTransportNetwork.instance_class)

function m:update_extractor_duct(extractor_hash, extractor, items_available)
end

function m:update_inserter_duct(inserter_hash, inserter, items_available)
end

function m:update_network(network, counter, delta)
  local extractors = network.members_by_type["extractors"]
  local inserters = network.members_by_type["inserters"]

  if extractors and inserters then
    local items_available = {}
    for extractor_hash,extractor in pairs(extractors) do
      if self:check_network_member(extractor, network) then
        self:update_extractor_duct(extractor_hash, extractor, items_available)
      end
    end

    for inserter_hash,inserter in pairs(inserters) do
      if self:check_network_member(inserter, network) then
        items_available = self:update_inserter_duct(inserter_hash, inserter, items_available)
      end
    end
  end
end

yatm_item_ducts.ItemTransportNetwork = ItemTransportNetwork:new({
  description = "Item Transport Network",
  abbr = "itn",
  node_interface_name = "item_transport_device",
})

do
  minetest.register_globalstep(function (delta)
    yatm_item_ducts.ItemTransportNetwork:update(delta)
  end)

  minetest.register_lbm({
    name = "yatm_item_ducts:item_transport_network_reload_lbm",
    nodenames = {
      "group:transporter_item_duct",
      "group:inserter_item_duct",
      "group:extractor_item_duct",
    },
    run_at_every_load = true,
    action = function (pos, node)
      yatm_item_ducts.ItemTransportNetwork:register_member(pos, node)
    end
  })
end
