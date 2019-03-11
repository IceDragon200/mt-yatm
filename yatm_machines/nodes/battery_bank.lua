local battery_bank_yatm_network = {
  kind = "energy_storage",
  groups = {
    energy_storage = 1,
  },
  states = {
    conflict = "yatm_machines:battery_bank_error",
    error = "yatm_machines:battery_bank_error",
    off = "yatm_machines:battery_bank_off",
    on = "yatm_machines:battery_bank_on",
  }
}

yatm.devices.register_network_device(battery_bank_yatm_network.states.off, {
  description = "Battery Bank",
  groups = {cracky = 1, yatm_network_host = 2},
  drop = battery_bank_yatm_network.states.off,
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
  yatm_network = battery_bank_yatm_network,
})

yatm.devices.register_network_device(battery_bank_yatm_network.states.error, {
  description = "Battery Bank",
  groups = {cracky = 1, yatm_network_host = 2, not_in_creative_inventory = 1},
  drop = battery_bank_yatm_network.states.off,
  tiles = {
    "yatm_battery_bank_top.error.png",
    "yatm_battery_bank_bottom.png",
    "yatm_battery_bank_side.png",
    "yatm_battery_bank_side.png^[transformFX",
    "yatm_battery_bank_back.level.0.png",
    "yatm_battery_bank_front.level.0.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = battery_bank_yatm_network,
})


yatm.devices.register_network_device(battery_bank_yatm_network.states.on, {
  description = "Battery Bank",
  groups = {cracky = 1, yatm_network_host = 2, not_in_creative_inventory = 1},
  drop = battery_bank_yatm_network.states.off,
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
  yatm_network = battery_bank_yatm_network,
})
