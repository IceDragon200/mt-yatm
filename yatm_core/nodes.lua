minetest.register_node("yatm_core:face_test", {
  description = "Face Test",
  groups = {cracky = 1},
  tiles = {
    "yatm_debug_6.png",
    "yatm_debug_5.png",
    "yatm_debug_2.png",
    "yatm_debug_4.png",
    "yatm_debug_1.png",
    "yatm_debug_3.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
})

dofile(yatm_core.modpath .. "/nodes/fluid_tanks.lua")
