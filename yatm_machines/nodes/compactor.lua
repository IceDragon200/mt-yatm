local compactor_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    machine_worker = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:compactor_error",
    error = "yatm_machines:compactor_error",
    off = "yatm_machines:compactor_off",
    on = "yatm_machines:compactor_on",
  },
  -- compactors require a lot of energy and have a small capacity
  energy_capacity = 20 * 60 * 10,
  startup_energy_threshold = 600,
  work_rate_energy_threshold = 600,
  work_energy_bandwidth = 100,
  network_charge_bandwidth = 400,
}

function compactor_yatm_network.work(pos, node, energy, work_rate)
  print("compacting", pos.x, pos.y, pos.z, node.name, energy, work_rate)
  return 0
end

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
  yatm_network = yatm_core.merge_tables(compactor_yatm_network, {state = "off"}),
})

yatm_machines.register_network_device("yatm_machines:compactor_error", {
  description = "Compactor",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  yatm_network = yatm_core.merge_tables(compactor_yatm_network, {state = "error"}),
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
  yatm_network = yatm_core.merge_tables(compactor_yatm_network, {state = "on"}),
})
