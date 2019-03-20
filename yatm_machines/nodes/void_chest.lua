local void_chest_yatm_network = {
  kind = "machine",
  groups = {
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:void_chest_error",
    error = "yatm_machines:void_chest_error",
    off = "yatm_machines:void_chest_off",
    on = "yatm_machines:void_chest_on",
  },
  energy = {
    passive_lost = 1,
  },
}

local groups = {
  cracky = 1,
  item_interface_out = 1,
  item_interface_in = 1,
  yatm_energy_device = 1,
  yatm_data_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Void Chest",

  groups = groups,

  drop = void_chest_yatm_network.states.off,

  tiles = {
    "yatm_void_chest_top.off.png",
    "yatm_void_chest_bottom.png",
    "yatm_void_chest_side.off.png",
    "yatm_void_chest_side.off.png^[transformFX",
    "yatm_void_chest_back.off.png",
    "yatm_void_chest_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = void_chest_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_void_chest_top.error.png",
      "yatm_void_chest_bottom.png",
      "yatm_void_chest_side.error.png",
      "yatm_void_chest_side.error.png^[transformFX",
      "yatm_void_chest_back.error.png",
      "yatm_void_chest_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_void_chest_top.on.png",
      "yatm_void_chest_bottom.png",
      {
        name = "yatm_void_chest_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      {
        name = "yatm_void_chest_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2
        },
      },
      "yatm_void_chest_back.on.png",
      "yatm_void_chest_front.on.png",
    },
  }
})
