minetest.register_node("yatm_machines:wireless_receiver", {
  basename = "yatm_machines:wireless_receiver",

  description = "Wireless Receiver",

  groups = {cracky = 1},

  tiles = {
    "yatm_wireless_receiver_top.on.png",
    "yatm_wireless_receiver_bottom.png",
    "yatm_wireless_receiver_side.on.png",
    "yatm_wireless_receiver_side.on.png^[transformFX",
    {
      name = "yatm_wireless_receiver_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    -- "yatm_wireless_receiver_front.off.png",
    {
      name = "yatm_wireless_receiver_front.on.png",
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
