local electric_molder_yatm_network = {
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
    conflict = "yatm_foundry:electric_molder_error",
    error = "yatm_foundry:electric_molder_error",
    off = "yatm_foundry:electric_molder_off",
    on = "yatm_foundry:electric_molder_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

function electric_molder_yatm_network.work(pos, node, available_energy, work_rate, ot)
end

local groups = {
  cracky = 1,
  fluid_interface_in = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Electric Molder",

  groups = groups,

  drop = electric_molder_yatm_network.states.off,

  tiles = {
    "yatm_electric_molder_top.off.png",
    "yatm_electric_molder_bottom.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png",
    "yatm_electric_molder_side.off.png"
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, (12 / 16.0) - 0.5, 0.5}, -- Base
      {-0.5, (15 / 16.0) - 0.5, -0.5, 0.5, 0.5, 0.5}, -- Cap
      -- Columns
      {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
      {(1 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (3 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
      {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (1 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (3 / 16.0) - 0.5},
      {(13 / 16.0) - 0.5, (12 / 16.0) - 0.5, (13 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5, (15 / 16.0) - 0.5},
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = electric_molder_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_electric_molder_top.error.png",
      "yatm_electric_molder_bottom.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png",
      "yatm_electric_molder_side.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_electric_molder_top.on.png",
      "yatm_electric_molder_bottom.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png",
      "yatm_electric_molder_side.on.png"
    },
  },
})

