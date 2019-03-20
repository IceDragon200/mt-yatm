local flux_furnace_yatm_network = {
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
    conflict = "yatm_machines:flux_furnace_error",
    error = "yatm_machines:flux_furnace_error",
    off = "yatm_machines:flux_furnace_off",
    on = "yatm_machines:flux_furnace_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

function flux_furnace_yatm_network.work(pos, node, available_energy, work_rate, ot)
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Flux Furnace",

  groups = groups,

  drop = flux_furnace_yatm_network.states.off,

  tiles = {
    "yatm_flux_furnace_top.off.png",
    "yatm_flux_furnace_bottom.png",
    "yatm_flux_furnace_side.off.png",
    "yatm_flux_furnace_side.off.png^[transformFX",
    "yatm_flux_furnace_back.png",
    "yatm_flux_furnace_front.off.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = flux_furnace_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_flux_furnace_top.error.png",
      "yatm_flux_furnace_bottom.png",
      "yatm_flux_furnace_side.error.png",
      "yatm_flux_furnace_side.error.png^[transformFX",
      "yatm_flux_furnace_back.png",
      "yatm_flux_furnace_front.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_flux_furnace_top.on.png",
      "yatm_flux_furnace_bottom.png",
      "yatm_flux_furnace_side.on.png",
      "yatm_flux_furnace_side.on.png^[transformFX",
      "yatm_flux_furnace_back.png",
      "yatm_flux_furnace_front.on.png"
    },
    light_source = 7,
  },
})

