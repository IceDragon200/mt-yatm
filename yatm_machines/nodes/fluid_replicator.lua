local fluid_replicator_yatm_network = {
  kind = "monitor",
  groups = {
    creative_replicator = 1,
  },
  states = {
    error = "yatm_machines:fluid_replicator_error",
    conflict = "yatm_machines:fluid_replicator_error",
    off = "yatm_machines:fluid_replicator_off",
    on = "yatm_machines:fluid_replicator_on",
  },
}

yatm_machines.register_network_device(fluid_replicator_yatm_network.states.off, {
  description = "Fluid Replicator",
  groups = {cracky = 1},
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.off.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.off.png",
    "yatm_fluid_replicator_side.off.png^[transformFX",
    "yatm_fluid_replicator_back.off.png",
    "yatm_fluid_replicator_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
})

yatm_machines.register_network_device(fluid_replicator_yatm_network.states.error, {
  description = "Fluid Replicator",
  groups = {cracky = 1},
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.error.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.error.png",
    "yatm_fluid_replicator_side.error.png^[transformFX",
    "yatm_fluid_replicator_back.error.png",
    "yatm_fluid_replicator_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
})

yatm_machines.register_network_device(fluid_replicator_yatm_network.states.on, {
  description = "Fluid Replicator",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = fluid_replicator_yatm_network.states.off,
  tiles = {
    "yatm_fluid_replicator_top.on.png",
    "yatm_fluid_replicator_bottom.png",
    "yatm_fluid_replicator_side.on.png",
    "yatm_fluid_replicator_side.on.png^[transformFX",
    {
      name = "yatm_fluid_replicator_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    {
      name = "yatm_fluid_replicator_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = fluid_replicator_yatm_network,
})
