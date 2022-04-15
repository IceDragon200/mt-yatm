local yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_device_hubs:hub_card_error",
    conflict = "yatm_device_hubs:hub_card_error",
    off = "yatm_device_hubs:hub_card_off",
    on = "yatm_device_hubs:hub_card_on",
  },
  energy = {
    capacity = 200,
    passive_lost = 0,
    network_charge_bandwidth = 10,
    startup_threshold = 1,
  }
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_device_hubs:hub_card",

  basename = "yatm_device_hubs:hub_card",

  description = "Hub (Card)",

  groups = {cracky = 1},

  drop = yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_card_hub_top.png",
    "yatm_card_hub_bottom.png",
    "yatm_card_hub_side.png",
    "yatm_card_hub_side.png^[transformFX",
    "yatm_card_hub_side.png",
    "yatm_card_hub_front.png",
  },
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.375, -0.5, -0.375, 0.375, (5 / 16.0) - 0.5, 0.375},
    }
  },

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = yatm_device_hubs.hub_after_place_node,

  yatm_network = yatm_network,

  refresh_infotext = yatm_device_hubs.hub_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_card_hub_top.png",
      "yatm_card_hub_bottom.png",
      "yatm_card_hub_side.png",
      "yatm_card_hub_side.png^[transformFX",
      "yatm_card_hub_side.png",
      "yatm_card_hub_front.png",
    },
  },
  on = {
    tiles = {
      "yatm_card_hub_top.png",
      "yatm_card_hub_bottom.png",
      "yatm_card_hub_side.png",
      "yatm_card_hub_side.png^[transformFX",
      "yatm_card_hub_side.png",
      "yatm_card_hub_front.png",
    },
  },
})
