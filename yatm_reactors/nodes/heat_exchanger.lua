local heat_exchanger_yatm_network = {
  kind = "machine",
  groups = {
    reactor = 1,
    heat_exchanger = 1,
  },
  states = {
    conflict = "yatm_reactors:heat_exchanger_error",
    error = "yatm_reactors:heat_exchanger_error",
    off = "yatm_reactors:heat_exchanger_off",
    on = "yatm_reactors:heat_exchanger_on",
  }
}

yatm_machines.register_network_device(heat_exchanger_yatm_network.states.off, {
  description = "Reactor Heat Exchanger",
  groups = {cracky = 1},
  drop = heat_exchanger_yatm_network.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_heat_exchanger_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = heat_exchanger_yatm_network,
})

yatm_machines.register_network_device(heat_exchanger_yatm_network.states.error, {
  description = "Reactor Heat Exchanger",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = heat_exchanger_yatm_network.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_heat_exchanger_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = heat_exchanger_yatm_network,
})

yatm_machines.register_network_device(heat_exchanger_yatm_network.states.on, {
  description = "Reactor Heat Exchanger",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = heat_exchanger_yatm_network.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_heat_exchanger_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = heat_exchanger_yatm_network,
})
