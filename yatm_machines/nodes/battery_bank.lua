local server_yatm_network = {
  kind = "machine",
  group = {machine = 1}
}

minetest.register_node("yatm_machines:battery_bank_off", {
  description = "Battery Bank",
  groups = {cracky = 1},
  tiles = {
    "yatm_battery_bank_top.off.png",
    "yatm_battery_bank_bottom.png",
    "yatm_battery_bank_side.png",
    "yatm_battery_bank_side.png^[transformFX",
    "yatm_battery_bank_back.level.0.png",
    "yatm_battery_bank_front.level.0.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = server_yatm_network,
})

minetest.register_node("yatm_machines:battery_bank_on", {
  description = "Battery Bank",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  yatm_network = server_yatm_network,
})
