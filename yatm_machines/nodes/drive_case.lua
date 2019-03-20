local drive_case_yatm_network = {
  kind = "machine",

  groups = {
    drive_case = 1,
    energy_consumer = 1,
    item_storage = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_machines:drive_case_error",
    error = "yatm_machines:drive_case_error",
    off = "yatm_machines:drive_case_off",
    on = "yatm_machines:drive_case_on",
  },

  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Drive Case",

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
    yatm_data_device = 1,
  },

  drop = drive_case_yatm_network.states.off,

  tiles = {
    "yatm_drive_case_top.off.png",
    "yatm_drive_case_bottom.png",
    "yatm_drive_case_side.off.png",
    "yatm_drive_case_side.off.png^[transformFX",
    "yatm_drive_case_back.off.png",
    "yatm_drive_case_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = drive_case_yatm_network,
}, {
  on = {
    tiles = {
      "yatm_drive_case_top.on.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.on.png",
      "yatm_drive_case_side.on.png^[transformFX",
      "yatm_drive_case_back.on.png",
      "yatm_drive_case_front.on.png"
    },
  },
  error = {
    tiles = {
      "yatm_drive_case_top.error.png",
      "yatm_drive_case_bottom.png",
      "yatm_drive_case_side.error.png",
      "yatm_drive_case_side.error.png^[transformFX",
      "yatm_drive_case_back.error.png",
      "yatm_drive_case_front.error.png"
    },
  }
})
