local network_yatm_network = {
  kind = "controller",
  groups = {
    controller = 1,
  },
  states = {
    conflict = "yatm_machines:network_controller_error",
    error = "yatm_machines:network_controller_error",
    on = "yatm_machines:network_controller_on",
    off = "yatm_machines:network_controller_off",
  }
}

yatm_machines.register_network_device("yatm_machines:network_controller_off", {
  description = "Network Controller",
  groups = {cracky = 1, yatm_network_host = 1},
  tiles = {
    "yatm_network_controller_top.off.png",
    "yatm_network_controller_bottom.png",
    "yatm_network_controller_side.off.png",
    "yatm_network_controller_side.off.png^[transformFX",
    "yatm_network_controller_back.off.png",
    "yatm_network_controller_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = network_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:network_controller_error", {
  description = "Network Controller",
  drop = "yatm_machines:network_controller_off",
  groups = {cracky = 1, not_in_creative_inventory = 1, yatm_network_host = 1},
  tiles = {
    "yatm_network_controller_top.error.png",
    "yatm_network_controller_bottom.png",
    "yatm_network_controller_side.error.png",
    "yatm_network_controller_side.error.png^[transformFX",
    "yatm_network_controller_back.error.png",
    "yatm_network_controller_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = network_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:network_controller_on", {
  description = "Network Controller",
  drop = "yatm_machines:network_controller_off",
  groups = {cracky = 1, not_in_creative_inventory = 1, yatm_network_host = 1},
  tiles = {
    {
      name = "yatm_network_controller_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
    "yatm_network_controller_bottom.png",
    {
      name = "yatm_network_controller_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
    {
      name = "yatm_network_controller_side.on.png^[transformFX",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
    "yatm_network_controller_back.on.png",
    "yatm_network_controller_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = network_yatm_network,
})
