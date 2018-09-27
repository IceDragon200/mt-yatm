local compactor_yatm_network = {
  kind = "machine",
  group = {machine = 1},
  states = {
    conflict = "yatm_machines:compactor_error",
    error = "yatm_machines:compactor_error",
    off = "yatm_machines:compactor_off",
    on = "yatm_machines:compactor_on",
  }
}

yatm_machines.register_network_device("yatm_machines:compactor_off", {
  description = "Compactor",
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
  yatm_network = compactor_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:compactor_error", {
  description = "Compactor",
  groups = {cracky = 1},
  tiles = {
    "yatm_compactor_top.error.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.png",
    "yatm_compactor_side.png",
    "yatm_compactor_back.error.png",
    "yatm_compactor_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = compactor_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:compactor_on", {
  description = "Compactor",
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
  yatm_network = compactor_yatm_network,
})
