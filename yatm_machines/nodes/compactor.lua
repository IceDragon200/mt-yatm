minetest.register_node("yatm_machines:compactor_off", {
  description = "Compactor [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_compactor_top.off.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.png",
    "yatm_compactor_side.png",
    "yatm_compactor_back.off.png",
    "yatm_compactor_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_machines:compactor_on", {
  description = "Compactor [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_compactor_top.on.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.png",
    "yatm_compactor_side.png",
    "yatm_compactor_back.on.png",
    {
      name = "yatm_compactor_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }
  },
  paramtype = "light",
  paramtype2 = "facedir",
})
