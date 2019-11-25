local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_memory", {
  description = "Data Memory",

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

  tiles = {
    "yatm_data_memory_top.png",
    "yatm_data_memory_bottom.png",
    "yatm_data_memory_side.png",
    "yatm_data_memory_side.png",
    "yatm_data_memory_side.png",
    "yatm_data_memory_side.png",
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
})
