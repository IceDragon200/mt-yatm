local data_network = assert(yatm.data_network)

yatm.register_stateful_node("yatm_data_logic:data_toggle_button", {
  description = "Data Toggle Button",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(),
    },
  },

  data_network_device = {
    type = "device",
  },
  data_interface = {
    receive_pdu = function (pos, node, port, value)
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  left = {
    tiles = {
      "yatm_data_toggle_button_top.left.png",
      "yatm_data_toggle_button_bottom.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
    },

    on_rightclick = function (pos, node, clicker)
      node.name = "yatm_data_logic:data_toggle_button_right"
      minetest.swap_node(pos, node)

      -- TODO: emit event
    end,
  },

  right = {
    tiles = {
      "yatm_data_toggle_button_top.right.png",
      "yatm_data_toggle_button_bottom.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
    },

    on_rightclick = function (pos, node, clicker)
      node.name = "yatm_data_logic:data_toggle_button_left"
      minetest.swap_node(pos, node)

      -- TODO: emit event
    end,
  },
})
