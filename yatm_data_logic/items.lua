minetest.register_tool("yatm_data_logic:data_programmer", {
  description = "Data Programmer\nRight-click on programmable data device.",

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
        -- TODO: determine data configuration and display programming interface
        minetest.log("action", user:get_player_name() .. " readies to program " .. node.name)
      end
    end
  end,
})
