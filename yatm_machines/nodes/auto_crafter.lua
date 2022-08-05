local mod = yatm_machines

local yatm_network = {
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
    idle = "yatm_machines:auto_crafter_idle",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

function yatm_network:work(ctx)
  return 0
end

local groups = {
  cracky = 1,
  yatm_energy_device = 1,
  item_interface_out = 1,
  item_interface_in = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("auto_crafter"),

  basename = mod:make_name("auto_crafter"),

  description = mod.S("Auto Crafter"),
  groups = groups,

  drop = yatm_network.states.off,

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

  yatm_network = yatm_network,
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
  idle = {
    tiles = {
      "yatm_auto_crafter_top.idle.png",
      "yatm_auto_crafter_bottom.png",
      "yatm_auto_crafter_side.idle.png",
      "yatm_auto_crafter_side.idle.png^[transformFX",
      "yatm_auto_crafter_back.idle.png",
      "yatm_auto_crafter_front.idle.png",
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
