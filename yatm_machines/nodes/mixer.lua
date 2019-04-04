local mixer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:mixer_error",
    error = "yatm_machines:mixer_error",
    off = "yatm_machines:mixer_off",
    on = "yatm_machines:mixer_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 100,
  },
}

function mixer_yatm_network.work(pos, node, available_energy, work_rate, ot)
  return 0
end

yatm.devices.register_stateful_network_device({
  description = "Mixer",

  groups = {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
    yatm_energy_device = 1,
  },

  drop = mixer_yatm_network.states.off,

  tiles = {
    "yatm_mixer_top.off.png",
    "yatm_mixer_bottom.png",
    "yatm_mixer_side.off.png",
    "yatm_mixer_side.off.png^[transformFX",
    "yatm_mixer_back.png",
    "yatm_mixer_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = mixer_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_mixer_top.error.png",
      "yatm_mixer_bottom.png",
      "yatm_mixer_side.error.png",
      "yatm_mixer_side.error.png^[transformFX",
      "yatm_mixer_back.png",
      "yatm_mixer_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_mixer_top.on.png",
      "yatm_mixer_bottom.png",
      "yatm_mixer_side.on.png",
      "yatm_mixer_side.on.png^[transformFX",
      "yatm_mixer_back.png",
      {
        name = "yatm_mixer_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 0.25
        },
      },
    },
  }
})
