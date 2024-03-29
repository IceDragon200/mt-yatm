--
-- Element Hubs are passive element producers, they slowly capture element over time.
--
local yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    element_producer = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_device_hubs:hub_elegens_error",
    conflict = "yatm_device_hubs:hub_elegens_error",
    off = "yatm_device_hubs:hub_elegens_off",
    on = "yatm_device_hubs:hub_elegens_on",
  },
  energy = {
    capacity = 200,
    passive_lost = 1,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_device_hubs:hub_ele",

  description = "Hub (Element)",
  groups = {
    cracky = nokore.dig_class("copper"),
  },
  drop = yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_hub_top.ele.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png^[transformFX",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = yatm_device_hubs.HUB_NODEBOX,

  after_place_node = yatm_device_hubs.hub_after_place_node,

  yatm_network = yatm_network,

  refresh_infotext = yatm_device_hubs.hub_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_hub_top.ele.error.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png^[transformFX",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_hub_top.ele.on.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png^[transformFX",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png",
    },
  },
})
