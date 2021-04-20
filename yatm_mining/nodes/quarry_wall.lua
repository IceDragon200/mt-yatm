local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

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
  use_texture_alpha = "clip",

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

    fixed = ng(7, 0, 7, 2, 14, 2),
    connect_front = ng(7, 0, 0, 2, 14, 7),
    connect_back = ng(7, 0, 9, 2, 14, 7),
    connect_left = ng(0, 0, 7, 7, 14, 2),
    connect_right = ng(9, 0, 7, 7, 14, 2),
  }
})
