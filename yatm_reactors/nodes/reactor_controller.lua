local cluster_devices = assert(yatm.cluster.devices)

local reactor_controller_yatm_network = {
  kind = "machine",
  groups = {
    device_controller = 4,
    reactor = 1,
    reactor_controller = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_reactors:reactor_controller_error",
    error = "yatm_reactors:reactor_controller_error",
    off = "yatm_reactors:reactor_controller_off",
    on = "yatm_reactors:reactor_controller_on",
  }
}

yatm.devices.register_stateful_network_device({
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
}, {
  error = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_controller_front.on.png"
    },
  }
})
