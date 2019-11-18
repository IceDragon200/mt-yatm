local item_transport_network = yatm.item_transport.ItemTransportNetwork

minetest.register_tool("yatm_item_ducts:item_transport_network_debug_tool", {
  description = "YATM Transport Network Debug Tool\nLeft Click on any network node",

  groups = {
    debug_tool = 1,
  },

  inventory_image = "yatm_transport_network_debug_tool.png",

  on_use = function (item_stack, user, pointed_thing)
    local member = item_transport_network:get_member(pointed_thing.under)
    if member then
      local network = item_transport_network:get_network(member.network_id)
      if network then
        network.debug = not network.debug

        minetest.chat_send_player(user:get_player_name(), "Toggled network debug: " .. tostring(network.debug))
      end
    end

    return nil
  end,
})
