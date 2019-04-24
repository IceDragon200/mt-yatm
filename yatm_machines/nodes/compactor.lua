local compactor_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    machine_worker = 1, -- the device should be updated every network step
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:compactor_error",
    error = "yatm_machines:compactor_error",
    off = "yatm_machines:compactor_off",
    on = "yatm_machines:compactor_on",
  },
  energy = {
    -- compactors require a lot of energy and have a small capacity
    capacity = 20 * 60 * 10,
    passive_lost = 0,
    startup_threshold = 600,
    work_rate_threshold = 600,
    work_bandwidth = 100,
    network_charge_bandwidth = 1000,
  },
}

function compactor_yatm_network.work(pos, node, energy, work_rate, dtime, ot)
  --print("compacting", pos.x, pos.y, pos.z, node.name, energy, work_rate)
  return 1
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_network_device(compactor_yatm_network.states.off, {
  description = "Compactor",
  groups = groups,
  drop = compactor_yatm_network.states.off,
  tiles = {
    "yatm_compactor_top.off.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.off.png",
    "yatm_compactor_side.off.png^[transformFX",
    "yatm_compactor_back.off.png",
    "yatm_compactor_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(compactor_yatm_network, {state = "off"}),
})

yatm.devices.register_network_device(compactor_yatm_network.states.error, {
  description = "Compactor",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = compactor_yatm_network.states.off,
  tiles = {
    "yatm_compactor_top.error.png",
    "yatm_compactor_bottom.png",
    "yatm_compactor_side.error.png",
    "yatm_compactor_side.error.png^[transformFX",
    "yatm_compactor_back.error.png",
    "yatm_compactor_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(compactor_yatm_network, {state = "error"}),
})

yatm.devices.register_network_device(compactor_yatm_network.states.on, {
  description = "Compactor",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = compactor_yatm_network.states.off,
  tiles = {
    "yatm_compactor_top.on.png",
    "yatm_compactor_bottom.png",
    --"yatm_compactor_side.on.png",
    --"yatm_compactor_side.on.png",
    {
      name = "yatm_compactor_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 4.0
      },
    },
    {
      name = "yatm_compactor_side.on.png^[transformFX",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 4.0
      },
    },
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
  yatm_network = yatm_core.table_merge(compactor_yatm_network, {state = "on"}),
})
