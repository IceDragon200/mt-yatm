local cluster_devices = assert(yatm.cluster.devices)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local network_controller_yatm_network = {
  kind = "controller",
  groups = {
    device_controller = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:network_controller_error",
    error = "yatm_machines:network_controller_error",
    on = "yatm_machines:network_controller_on",
    off = "yatm_machines:network_controller_off",
  },
}

local groups = {
  cracky = 1, yatm_network_device = 1,
              yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Network Controller",

  groups = groups,

  drop = network_controller_yatm_network.states.off,

  sounds = default.node_sound_metal_defaults(),

  tiles = {
    "yatm_network_controller_top.off.png",
    "yatm_network_controller_bottom.png",
    "yatm_network_controller_side.off.png",
    "yatm_network_controller_side.off.png^[transformFX",
    "yatm_network_controller_back.off.png",
    "yatm_network_controller_front.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = network_controller_yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_network_controller_top.error.png",
      "yatm_network_controller_bottom.png",
      "yatm_network_controller_side.error.png",
      "yatm_network_controller_side.error.png^[transformFX",
      "yatm_network_controller_back.error.png",
      "yatm_network_controller_front.error.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_network_controller_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_network_controller_bottom.png",
      {
        name = "yatm_network_controller_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      {
        name = "yatm_network_controller_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_network_controller_back.on.png",
      "yatm_network_controller_front.on.png",
    }
  },
})
