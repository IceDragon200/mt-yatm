local heater_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_heater_error",
    error = "yatm_foundry:electric_heater_error",
    off = "yatm_foundry:electric_heater_off",
    on = "yatm_foundry:electric_heater_on",
  },
  energy = {
    passive_lost = 100, -- heaters devour energy like no tomorrow
  },
}

yatm.devices.register_stateful_network_device({
  description = "Electric Heater",

  groups = { cracky = 1, heating_device = 1 },

  drop = heater_yatm_network.states.off,

  tiles = {
    "yatm_heater_top.off.png",
    "yatm_heater_bottom.png",
    "yatm_heater_side.off.png",
    "yatm_heater_side.off.png^[transformFX",
    "yatm_heater_back.off.png",
    "yatm_heater_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = heater_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_heater_top.error.png",
      "yatm_heater_bottom.png",
      "yatm_heater_side.error.png",
      "yatm_heater_side.error.png^[transformFX",
      "yatm_heater_back.error.png",
      "yatm_heater_front.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_heater_top.on.png",
      "yatm_heater_bottom.png",
      "yatm_heater_side.on.png",
      "yatm_heater_side.on.png^[transformFX",
      "yatm_heater_back.on.png",
      "yatm_heater_front.on.png"
    },
    light_source = 7,
  },
})
