local crusher_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:crusher_error",
    error = "yatm_machines:crusher_error",
    off = "yatm_machines:crusher_off",
    on = "yatm_machines:crusher_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    startup_threshold = 100,
    network_charge_bandwidth = 1000,
  }
}

function crusher_yatm_network.work(pos, node, available_energy, work_rate, ot)
  --
end

yatm.devices.register_stateful_network_device({
  description = "Crusher",

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
    item_interface_in = 1,
    item_interface_out = 1,
  },

  drop = crusher_yatm_network.states.off,

  tiles = {
    "yatm_crusher_top.off.png",
    "yatm_crusher_bottom.png",
    "yatm_crusher_side.off.png",
    "yatm_crusher_side.off.png^[transformFX",
    "yatm_crusher_back.off.png",
    "yatm_crusher_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = crusher_yatm_network,
}, {
  on = {
    tiles = {
      "yatm_crusher_top.on.png",
      "yatm_crusher_bottom.png",
      "yatm_crusher_side.on.png",
      "yatm_crusher_side.on.png^[transformFX",
      "yatm_crusher_back.on.png",
      --"yatm_crusher_front.off.png"
      {
        name = "yatm_crusher_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.5
        },
      },
    },
  },
  error = {
    tiles = {
      "yatm_crusher_top.error.png",
      "yatm_crusher_bottom.png",
      "yatm_crusher_side.error.png",
      "yatm_crusher_side.error.png^[transformFX",
      "yatm_crusher_back.error.png",
      "yatm_crusher_front.error.png",
    },
  }
})
