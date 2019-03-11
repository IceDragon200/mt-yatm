local compute_module_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  states = {
    conflict = "yatm_machines:compute_module_error",
    error = "yatm_machines:compute_module_error",
    off = "yatm_machines:compute_module_off",
    on = "yatm_machines:compute_module_on",
  }
}

yatm.devices.register_network_device(compute_module_yatm_network.states.off, {
  description = "Compute Module",
  groups = {cracky = 1},
  drop = compute_module_yatm_network.states.off,
  tiles = {"yatm_compute_module_side.off.png"},
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = compute_module_yatm_network,
})

yatm.devices.register_network_device(compute_module_yatm_network.states.error, {
  description = "Compute Module",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = compute_module_yatm_network.states.off,
  tiles = {"yatm_compute_module_side.error.png"},
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = compute_module_yatm_network,
})

yatm.devices.register_network_device(compute_module_yatm_network.states.on, {
  description = "Compute Module",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = compute_module_yatm_network.states.on,
  tiles = {{
    name = "yatm_compute_module_side.on.png",
    animation = {
      type = "vertical_frames",
      aspect_w = 16,
      aspect_h = 16,
      length = 1.0
    },
  }},
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = compute_module_yatm_network,
})
