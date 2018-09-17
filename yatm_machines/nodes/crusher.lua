minetest.register_node("yatm_machines:crusher_off", {
  description = "Crusher [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_crusher_top.off.png",
    "yatm_crusher_bottom.png",
    "yatm_crusher_side.off.png",
    "yatm_crusher_side.off.png",
    "yatm_crusher_back.png",
    "yatm_crusher_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_machines:crusher_on", {
  description = "Crusher [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_crusher_top.on.png",
    "yatm_crusher_bottom.png",
    "yatm_crusher_side.on.png",
    "yatm_crusher_side.on.png",
    "yatm_crusher_back.png",
    --"yatm_crusher_front.off.png"
    {
      name = "yatm_crusher_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
})
