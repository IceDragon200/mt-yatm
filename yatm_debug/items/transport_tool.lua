local item_transport_network
local fluid_transport_network
if yatm.item_transport then
  item_transport_network = yatm.item_transport.item_transport_network
end
if yatm.fluids then
  fluid_transport_network = yatm.fluids.fluid_transport_network
end

yatm_debug:register_tool("transport_network_debug_tool", {
  description = "YATM Transport Network Debug Tool\nLeft Click on any network node",

  groups = {
    debug_tool = 1,
  },

  inventory_image = "yatm_transport_network_debug_tool.png",

  on_use = function (item_stack, user, pointed_thing)
    if item_transport_network then
      local member = item_transport_network:get_member(pointed_thing.under)
      if member then
        local network = item_transport_network:get_network(member.network_id)
        if network then
          network.debug = not network.debug

          minetest.chat_send_player(user:get_player_name(), "Toggled network debug: " .. tostring(network.debug))
        end
      end
    end

    if fluid_transport_network then
      local member = fluid_transport_network:get_member(pointed_thing.under)
      if member then
        local network = fluid_transport_network:get_network(member.network_id)
        if network then
          network.debug = not network.debug

          minetest.chat_send_player(user:get_player_name(), "Toggled network debug: " .. tostring(network.debug))
        end
      end
    end

    return nil
  end,
})

