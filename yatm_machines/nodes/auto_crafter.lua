local auto_crafter_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1, -- this is a worker module, it will consume energy to complete 'work'
    item_auto_crafter = 1,
    energy_consumer = 1,
    item_producer = 1,
    item_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:auto_crafter_error",
    error = "yatm_machines:auto_crafter_error",
    off = "yatm_machines:auto_crafter_off",
    on = "yatm_machines:auto_crafter_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

function auto_crafter_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  return 0
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_out = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:auto_crafter",

  description = "Auto Crafter",
  groups = groups,

  drop = auto_crafter_yatm_network.states.off,

  tiles = {
    "yatm_auto_crafter_top.off.png",
    "yatm_auto_crafter_bottom.png",
    "yatm_auto_crafter_side.off.png",
    "yatm_auto_crafter_side.off.png^[transformFX",
    "yatm_auto_crafter_back.off.png",
    "yatm_auto_crafter_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = auto_crafter_yatm_network,
}, {
  on = {
    tiles = {
      -- "yatm_auto_crafter_top.off.png",
      {
        name = "yatm_auto_crafter_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_auto_crafter_bottom.png",
      "yatm_auto_crafter_side.on.png",
      "yatm_auto_crafter_side.on.png^[transformFX",
      "yatm_auto_crafter_back.on.png",
      -- "yatm_auto_crafter_front.off.png"
      {
        name = "yatm_auto_crafter_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
    },
  },
  error = {
    tiles = {
      "yatm_auto_crafter_top.error.png",
      "yatm_auto_crafter_bottom.png",
      "yatm_auto_crafter_side.error.png",
      "yatm_auto_crafter_side.error.png^[transformFX",
      "yatm_auto_crafter_back.error.png",
      "yatm_auto_crafter_front.error.png",
    },
  },
})
