local data_network = assert(yatm.data_network)

yatm.register_stateful_node("yatm_data_logic:data_momentary_button", {
  description = "Data Momentary Button",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",

  data_network_device = {
    type = "device",
  },
  data_interface = {
    receive_pdu = function (pos, node, port, value)
    end,
  },

  on_timer = function (pos)
    local node = minetest.get_node(pos)

    if node.name == "yatm_data_logic:data_momentary_button_on" then
      node.name = "yatm_data_logic:data_momentary_button_off"

      minetest.swap_node(pos, node)
      -- TODO: emit data event
    end
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  off = {
    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(), -- base
        yatm_core.Cuboid:new(3, 4, 3, 10, 1, 10):fast_node_box(), -- button
      },
    },

    tiles = {
      "yatm_data_momentary_button_top.off.png",
      "yatm_data_momentary_button_bottom.png",
      "yatm_data_momentary_button_side.off.png",
      "yatm_data_momentary_button_side.off.png",
      "yatm_data_momentary_button_side.off.png",
      "yatm_data_momentary_button_side.off.png",
    },

    on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
      node.name = "yatm_data_logic:data_momentary_button_on"
      minetest.swap_node(pos, node)

      minetest.get_node_timer(pos):start(0.25)

      -- TODO: emit data event
    end,
  },

  on = {
    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(),
      },
    },

    tiles = {
      "yatm_data_momentary_button_top.on.png",
      "yatm_data_momentary_button_bottom.png",
      "yatm_data_momentary_button_side.on.png",
      "yatm_data_momentary_button_side.on.png",
      "yatm_data_momentary_button_side.on.png",
      "yatm_data_momentary_button_side.on.png",
    },
  },
})
