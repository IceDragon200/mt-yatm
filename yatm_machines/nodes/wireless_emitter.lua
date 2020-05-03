minetest.register_node("yatm_machines:wireless_emitter", {
  basename = "yatm_machines:wireless_emitter",

  description = "Wireless Emitter",

  groups = {cracky = 1},

  tiles = {
    "yatm_wireless_emitter_top.on.png",
    "yatm_wireless_emitter_bottom.png",
    "yatm_wireless_emitter_side.on.png",
    "yatm_wireless_emitter_side.on.png^[transformFX",
    {
      name = "yatm_wireless_emitter_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    {
      name = "yatm_wireless_emitter_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
  },
  paramtype = "none",
  paramtype2 = "facedir",
})
