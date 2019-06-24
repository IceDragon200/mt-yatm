local electric_kiln_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_kiln_error",
    error = "yatm_foundry:electric_kiln_error",
    off = "yatm_foundry:electric_kiln_off",
    on = "yatm_foundry:electric_kiln_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

function electric_kiln_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  return 0
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Electric Kiln",

  groups = groups,

  drop = electric_kiln_yatm_network.states.off,

  tiles = {
    "yatm_electric_kiln_top.off.png",
    "yatm_electric_kiln_bottom.off.png",
    "yatm_electric_kiln_side.off.png",
    "yatm_electric_kiln_side.off.png^[transformFX",
    "yatm_electric_kiln_back.off.png",
    "yatm_electric_kiln_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = electric_kiln_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_electric_kiln_top.error.png",
      "yatm_electric_kiln_bottom.error.png",
      "yatm_electric_kiln_side.error.png",
      "yatm_electric_kiln_side.error.png^[transformFX",
      "yatm_electric_kiln_back.error.png",
      "yatm_electric_kiln_front.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_electric_kiln_top.on.png",
      "yatm_electric_kiln_bottom.on.png",
      "yatm_electric_kiln_side.on.png",
      "yatm_electric_kiln_side.on.png^[transformFX",
      "yatm_electric_kiln_back.on.png",
      "yatm_electric_kiln_front.on.png"
    },
    light_source = 7,
  },
})

