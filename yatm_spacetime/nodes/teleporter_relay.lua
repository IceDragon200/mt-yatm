local Network = assert(yatm_spacetime.Network)

--[[
Teleporter relays are neutral nodes that are placed adjacent to a teleporter to expand it's teleportation effect range
]]
local teleporter_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (1 / 16) - 0.5, 0.5},
  }
}

local teleporter_relay_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    teleporter_relay = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_spacetime:teleporter_relay_error",
    error = "yatm_spacetime:teleporter_relay_error",
    off = "yatm_spacetime:teleporter_relay_off",
    on = "yatm_spacetime:teleporter_relay_on",
    inactive = "yatm_spacetime:teleporter_relay_inactive",
  },
  energy = {
    passive_lost = 5,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Teleporter Relay",
  groups = {cracky = 1, spacetime_device = 1},
  drop = teleporter_relay_yatm_network.states.off,
  tiles = {
    "yatm_teleporter_relay_top.off.png",
    "yatm_teleporter_relay_bottom.png",
    "yatm_teleporter_relay_side.off.png",
    "yatm_teleporter_relay_side.off.png^[transformFX",
    "yatm_teleporter_relay_side.off.png",
    "yatm_teleporter_relay_side.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = teleporter_node_box,
  yatm_network = teleporter_relay_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_teleporter_relay_top.error.png",
      "yatm_teleporter_relay_bottom.png",
      "yatm_teleporter_relay_side.error.png",
      "yatm_teleporter_relay_side.error.png^[transformFX",
      "yatm_teleporter_relay_side.error.png",
      "yatm_teleporter_relay_side.error.png",
    },
  },
  inactive = {
    tiles = {
      "yatm_teleporter_relay_top.inactive.png",
      "yatm_teleporter_relay_bottom.png",
      "yatm_teleporter_relay_side.inactive.png",
      "yatm_teleporter_relay_side.inactive.png^[transformFX",
      "yatm_teleporter_relay_side.inactive.png",
      "yatm_teleporter_relay_side.inactive.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_teleporter_relay_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      },
      "yatm_teleporter_relay_bottom.png",
      "yatm_teleporter_relay_side.on.png",
      "yatm_teleporter_relay_side.on.png^[transformFX",
      "yatm_teleporter_relay_side.on.png^[transformFX",
      "yatm_teleporter_relay_side.on.png",
    },
  },
})
