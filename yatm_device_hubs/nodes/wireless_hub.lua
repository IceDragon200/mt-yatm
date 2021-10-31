local yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    wireless_interface = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_device_hubs:hub_wireless_error",
    conflict = "yatm_device_hubs:hub_wireless_error",
    off = "yatm_device_hubs:hub_wireless_off",
    on = "yatm_device_hubs:hub_wireless_on",
  },
  energy = {
    capacity = 200,
    passive_lost = 1,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_device_hubs:hub_wireless",

  codex_entry_id = "yatm_device_hubs:hub_wireless",

  description = "Hub (wireless)",

  groups = {
    cracky = 1,
  },

  drop = yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_hub_top.wireless.off.png",
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

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)

    local meta = minetest.get_meta(pos)
    --meta:set_string("", "")
  end,

  after_place_node = yatm_device_hubs.hub_after_place_node,

  yatm_network = yatm_network,

  refresh_infotext = yatm_device_hubs.hub_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_hub_top.wireless.error.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png^[transformFX",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_hub_top.wireless.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_hub_bottom.png",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png^[transformFX",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png",
    },
  }
})
