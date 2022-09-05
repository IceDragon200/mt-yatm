minetest.register_node("yatm_core:face_debug", {
  description = "Face Debug",

  groups = {
    cracky = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
  },

  tiles = {
    "yatm_face_debug_yp.png", -- +Y
    "yatm_face_debug_ym.png", -- -Y
    "yatm_face_debug_xp.png", -- +X
    "yatm_face_debug_xm.png", -- -X
    "yatm_face_debug_zp.png", -- +Z
    "yatm_face_debug_zm.png"  -- -Z
  },
  use_texture_alpha = "opaque",

  paramtype = "none",
  paramtype2 = "facedir",

  is_ground_content = false,
})

minetest.register_node("yatm_core:grid_block", {
  description = "GRID\nDummy Block",

  groups = {
    cracky = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
  },

  tiles = {
    "yatm_grid.png",
  },
  use_texture_alpha = "clip",

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, -0.49, 0.5}
    }
  }
})
