local roller_yatm_network = {
  kind = "machine",
  groups = {machine = 1},
  states = {
    conflict = "yatm_machines:roller_error",
    error = "yatm_machines:roller_error",
    off = "yatm_machines:roller_off",
    on = "yatm_machines:roller_on",
  }
}

yatm_machines.register_network_device("yatm_machines:roller_off", {
  description = "Roller",
  groups = {cracky = 1},
  tiles = {
    "yatm_roller_top.off.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.off.png",
    "yatm_roller_side.off.png^[transformFX",
    "yatm_roller_back.png",
    "yatm_roller_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = roller_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:roller_error", {
  description = "Roller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_roller_top.error.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.error.png",
    "yatm_roller_side.error.png^[transformFX",
    "yatm_roller_back.png",
    "yatm_roller_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = roller_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:roller_on", {
  description = "Roller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_roller_top.on.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.on.png",
    "yatm_roller_side.on.png^[transformFX",
    "yatm_roller_back.png",
    {
      name = "yatm_roller_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = roller_yatm_network,
})
