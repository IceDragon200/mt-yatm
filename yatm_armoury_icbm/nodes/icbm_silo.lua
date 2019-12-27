minetest.register_node("yatm_armoury_icbm:icbm_silo", {
  description = "ICBM Silo",

  groups = {
    cracky = 1,
  },

  tiles = {
    "yatm_icbm_silo_top.png",
    "yatm_icbm_silo_bottom.png",
    "yatm_icbm_silo_side.png",
    "yatm_icbm_silo_side.png",
    "yatm_icbm_silo_side.png",
    "yatm_icbm_silo_side.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    },
  },
})

local node_box = {
  type = "fixed",
  fixed = {
    yatm.Cuboid:new( 0,  2,  0, 15,  4,  1):fast_node_box(),
    yatm.Cuboid:new( 0, 10,  0, 15,  4,  1):fast_node_box(),

    yatm.Cuboid:new(15,  2,  0,  1,  4, 15):fast_node_box(),
    yatm.Cuboid:new(15, 10,  0,  1,  4, 15):fast_node_box(),

    yatm.Cuboid:new( 1,  2, 15, 15,  4,  1):fast_node_box(),
    yatm.Cuboid:new( 1, 10, 15, 15,  4,  1):fast_node_box(),

    yatm.Cuboid:new( 0,  2,  1,  1,  4, 15):fast_node_box(),
    yatm.Cuboid:new( 0, 10,  1,  1,  4, 15):fast_node_box(),
  },
}

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring", {
  description = "ICBM Guiding Ring",

  groups = {
    cracky = 1,
  },

  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  is_ground_content = false,
  sunlight_propogates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_warning_strips", {
  description = "ICBM Guiding Ring [Warning Strips]",

  groups = {
    cracky = 1,
  },

  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  is_ground_content = false,
  sunlight_propogates = true,
})
