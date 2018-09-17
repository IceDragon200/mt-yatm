local void_crate_side_animation = {
  name = "yatm_void_crate_side.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 2
  },
}

minetest.register_node("yatm_machines:void_crate_off", {
  description = "Void Crate [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_void_crate_top.off.png",
    "yatm_void_crate_bottom.png",
    "yatm_void_crate_side.off.png",
    "yatm_void_crate_side.off.png",
    "yatm_void_crate_back.off.png",
    "yatm_void_crate_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_machines:void_crate_on", {
  description = "Void Crate [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_void_crate_top.on.png",
    "yatm_void_crate_bottom.png",
    void_crate_side_animation,
    void_crate_side_animation,
    "yatm_void_crate_back.on.png",
    "yatm_void_crate_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
})
