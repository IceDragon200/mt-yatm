local data_network = assert(yatm.data_network)

minetest.register_tool("yatm_data_logic:data_programmer", {
  description = "Data Programmer\nRight-click on programmable DATA device.",

  groups = {
    data_programmer = 1,
  },

  inventory_image = "yatm_data_programmer.png",

  on_place = function (itemstack, user, pointed_thing)
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      if yatm_core.groups.get_item(nodedef, "data_programmable") then
        local di = data_network:get_data_interface(pos)
        if di then
          local assigns = { pos = pos, node = node }
          local formspec = di:get_programmer_formspec(pos, user, pointed_thing, assigns)
          local formspec_name = "yatm_data_logic:programmer:" .. minetest.pos_to_string(pos)

          yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                                  assigns,
                                                  function (...)
                                                    return di:receive_programmer_fields(...)
                                                  end)

          minetest.show_formspec(user:get_player_name(), formspec_name, formspec)
        else
          minetest.chat_send_player(user:get_player_name(), "This node cannot be programmed")
        end
        -- TODO: determine data configuration and display programming interface
        minetest.log("action", user:get_player_name() .. " readies to program " .. node.name)
      end
    end
  end,
})
