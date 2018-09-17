minetest.register_node("yatm_machines:battery_bank", {
  description = "Battery Bank",
  groups = {cracky = 1},
  tiles = {
    -- "yatm_battery_bank_top.on.png",
    {
      name = "yatm_battery_bank_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
    "yatm_battery_bank_bottom.png",
    "yatm_battery_bank_side.png",
    "yatm_battery_bank_side.png^[transformFX",
    "yatm_battery_bank_back.level.4.png",
    "yatm_battery_bank_front.level.4.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
})
