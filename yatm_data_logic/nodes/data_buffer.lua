local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_buffer", {
  description = "Data Buffer",

  groups = {
    cracky = 1,
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

  tiles = {
    "yatm_data_buffer_top.png",
    "yatm_data_buffer_bottom.png",
    "yatm_data_buffer_side.png",
    "yatm_data_buffer_side.png",
    "yatm_data_buffer_side.png",
    "yatm_data_buffer_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    meta:set_string("buffer", "")
  end,

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
})
