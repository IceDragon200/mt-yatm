local reactor_controller_yatm_network = {
  kind = "machine",
  groups = {
    reactor = 1,
    reactor_controller = 1,
  },
  states = {
    conflict = "yatm_reactors:reactor_controller_error",
    error = "yatm_reactors:reactor_controller_error",
    off = "yatm_reactors:reactor_controller_off",
    on = "yatm_reactors:reactor_controller_on",
  }
}

yatm_machines.register_network_device(reactor_controller_yatm_network.states.off, {
  description = "Reactor Controller",
  groups = {cracky = 1},
  drop = reactor_controller_yatm_network.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_controller_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = reactor_controller_yatm_network,
})

yatm_machines.register_network_device(reactor_controller_yatm_network.states.error, {
  description = "Reactor Controller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = reactor_controller_yatm_network.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_controller_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = reactor_controller_yatm_network,
})

yatm_machines.register_network_device(reactor_controller_yatm_network.states.on, {
  description = "Reactor Controller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = reactor_controller_yatm_network.states.off,
  tiles = {
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_controller_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = reactor_controller_yatm_network,
})
