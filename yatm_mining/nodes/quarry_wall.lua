minetest.register_node("yatm_mining:quarry_wall", {
  description = "Quarry Wall",

  groups = {
    snappy = 1,
  },

  tiles = {
    "yatm_quarry_wall_top.png",
    "yatm_quarry_wall_bottom.png",
    "yatm_quarry_wall_side.png",
    "yatm_quarry_wall_side.png",
    "yatm_quarry_wall_side.png",
    "yatm_quarry_wall_side.png",
  },

  sounds = yatm.node_sounds:build("glass"),

  connects_to = {
    "yatm_mining:quarry_wall",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,

  drawtype = "nodebox",
  node_box = {
    type = "connected",

    fixed = yatm_core.Cuboid:new(7, 0, 7, 2, 14, 2):fast_node_box(),
    connect_front = yatm_core.Cuboid:new(7, 0, 0, 2, 14, 7):fast_node_box(),
    connect_back = yatm_core.Cuboid:new(7, 0, 9, 2, 14, 7):fast_node_box(),
    connect_left = yatm_core.Cuboid:new(0, 0, 7, 7, 14, 2):fast_node_box(),
    connect_right = yatm_core.Cuboid:new(9, 0, 7, 7, 14, 2):fast_node_box(),
  }
})
