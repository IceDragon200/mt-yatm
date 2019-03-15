--[[
This Network handles Item Transport, devices can still handle their own item handling.

Only item ducts should register on this network.

The 3 main components of an item transport are:
* Inserters - these will insert items from the network and place them into their adjacent devices
* Extractors - these will extract items from adjacent devices for consumption by the network
* Transporters - these only act as a pathway for the network and only matter when tracing the path
]]
local GenericTransportNetwork = assert(yatm.transport.GenericTransportNetwork)

local ItemTransportNetwork = GenericTransportNetwork:extends()
local m = assert(ItemTransportNetwork.instance_class)

function m:update_network(network, counter, delta)
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