local data_network = assert(yatm.data_network)

-- Just like a mesecon noteblock, except triggered by data events
minetest.register_node("yatm_data_logic:data_noteblock", {
  description = "Data Note Block",

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
      yatm_core.Cuboid:new(0, 0, 0, 16, 5, 16):fast_node_box(),
      yatm_core.Cuboid:new(2, 5, 2, 12,10, 12):fast_node_box(),
      yatm_core.Cuboid:new( 0,14, 0, 16, 2, 2):fast_node_box(),
      yatm_core.Cuboid:new( 0,14,14, 16, 2, 2):fast_node_box(),
      yatm_core.Cuboid:new( 0,14, 0,  2, 2, 16):fast_node_box(),
      yatm_core.Cuboid:new(14,14, 0,  2, 2, 16):fast_node_box(),
    },
  },

  tiles = {
    "yatm_data_noteblock_top.png",
    "yatm_data_noteblock_bottom.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
    "yatm_data_noteblock_side.png",
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
