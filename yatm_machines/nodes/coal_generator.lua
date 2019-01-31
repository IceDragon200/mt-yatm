local coal_generator_yatm_network = {
  kind = "energy_producer",
  groups = {
    energy_producer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:coal_generator_error",
    error = "yatm_machines:coal_generator_error",
    off = "yatm_machines:coal_generator_off",
    on = "yatm_machines:coal_generator_on",
  }
}

yatm_machines.register_network_device("yatm_machines:coal_generator_off", {
  description = "Coal Generator",
  groups = {cracky = 1},
  tiles = {
    "yatm_coal_generator_top.off.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_side.off.png",
    "yatm_coal_generator_back.off.png",
    "yatm_coal_generator_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = coal_generator_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:coal_generator_error", {
  description = "Coal Generator",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_coal_generator_top.error.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.error.png",
    "yatm_coal_generator_side.error.png",
    "yatm_coal_generator_back.error.png",
    "yatm_coal_generator_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = coal_generator_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:coal_generator_on", {
  description = "Coal Generator",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    --"yatm_coal_generator_top.on.png",
    {
      name = "yatm_coal_generator_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.on.png",
    "yatm_coal_generator_side.on.png",
    "yatm_coal_generator_back.on.png",
    "yatm_coal_generator_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = coal_generator_yatm_network,
})
