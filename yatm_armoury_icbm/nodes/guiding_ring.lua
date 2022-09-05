local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local node_box = {
  type = "fixed",
  fixed = {
    ng( 0,  2,  0, 15,  4,  1),
    ng( 0, 10,  0, 15,  4,  1),

    ng(15,  2,  0,  1,  4, 15),
    ng(15, 10,  0,  1,  4, 15),

    ng( 1,  2, 15, 15,  4,  1),
    ng( 1, 10, 15, 15,  4,  1),

    ng( 0,  2,  1,  1,  4, 15),
    ng( 0, 10,  1,  1,  4, 15),
  },
}

local single_node_box = {
  type = "fixed",
  fixed = {
    ng( 0,  2,  0, 15, 12,  1),

    ng(15,  2,  0,  1, 12, 15),

    ng( 1,  2, 15, 15, 12,  1),

    ng( 0,  2,  1,  1, 12, 15),
  },
}

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring", {
  description = "ICBM Guiding Ring (Double Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = nokore.dig_class("copper"),
    icbm_guiding_ring = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
    "yatm_icbm_guiding_ring_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_single", {
  description = "ICBM Guiding Ring (Single Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = nokore.dig_class("copper"),
    icbm_guiding_ring = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_single_side.png",
    "yatm_icbm_guiding_ring_single_side.png",
    "yatm_icbm_guiding_ring_single_side.png",
    "yatm_icbm_guiding_ring_single_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = single_node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_warning_strips", {
  description = "ICBM Guiding Ring [Warning Strips] (Double Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = nokore.dig_class("copper"),
    icbm_guiding_ring = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
    "yatm_icbm_guiding_ring_warning_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})

minetest.register_node("yatm_armoury_icbm:icbm_guiding_ring_single_warning_strips", {
  description = "ICBM Guiding Ring [Warning Strips] (Single Band)",

  codex_entry_id = "yatm_armoury_icbm:icbm_guiding_ring",

  groups = {
    cracky = nokore.dig_class("copper"),
    icbm_guiding_ring = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_icbm_guiding_ring_top.png",
    "yatm_icbm_guiding_ring_bottom.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
    "yatm_icbm_guiding_ring_warning_single_side.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  drawtype = "nodebox",
  node_box = single_node_box,

  is_ground_content = false,
  sunlight_propagates = true,
})
