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

function coal_generator_yatm_network.produce_energy(pos, node, ot)
  return 0
end

function coal_generator_yatm_network.update(pos, node, ot)
end

local groups = {
  cracky = 1,
  yatm_network_host = 3,
  item_interface_in = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_network_device(coal_generator_yatm_network.states.off, {
  description = "Coal Generator",
  groups = groups,
  drop = coal_generator_yatm_network.states.off,
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

yatm.devices.register_network_device(coal_generator_yatm_network.states.error, {
  description = "Coal Generator",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = coal_generator_yatm_network.states.off,
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

yatm.devices.register_network_device(coal_generator_yatm_network.states.on, {
  description = "Coal Generator",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = coal_generator_yatm_network.states.off,
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
