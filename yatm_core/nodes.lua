minetest.register_node("yatm_core:face_debug", {
  description = "Face Debug",

  groups = {cracky = 1},

  tiles = {
    "yatm_face_debug_yp.png", -- +Y
    "yatm_face_debug_ym.png", -- -Y
    "yatm_face_debug_xp.png", -- +X
    "yatm_face_debug_xm.png", -- -X
    "yatm_face_debug_zp.png", -- +Z
    "yatm_face_debug_zm.png"  -- -Z
  },

  paramtype = "light",
  paramtype2 = "facedir",

  is_ground_content = false,

})
