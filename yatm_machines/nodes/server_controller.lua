--[[
Not sure what I'm going to do with this, but it looks pretty cute.
]]
local server_controller_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
  }
}

local server_controller_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:server_controller_error",
    error = "yatm_machines:server_controller_error",
    off = "yatm_machines:server_controller_off",
    on = "yatm_machines:server_controller_on",
  },
  energy = {
    passive_lost = 5
  }
}

yatm.devices.register_stateful_network_device({
  description = "Server Controller",

  groups = {cracky = 1},

  drop = server_controller_yatm_network.states.off,

  tiles = {
    "yatm_server_controller_top.off.png",
    "yatm_server_controller_bottom.png",
    "yatm_server_controller_side.off.png",
    "yatm_server_controller_side.off.png^[transformFX",
    "yatm_server_controller_back.off.png",
    "yatm_server_controller_front.off.png",
  },
  drawtype = "nodebox",
  node_box = server_controller_node_box,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = server_controller_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_server_controller_top.error.png",
      "yatm_server_controller_bottom.png",
      "yatm_server_controller_side.error.png",
      "yatm_server_controller_side.error.png^[transformFX",
      "yatm_server_controller_back.error.png",
      "yatm_server_controller_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_server_controller_top.on.png",
      "yatm_server_controller_bottom.png",
      "yatm_server_controller_side.on.png",
      "yatm_server_controller_side.on.png^[transformFX",
      "yatm_server_controller_back.on.png",
      {
        name = "yatm_server_controller_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      }
    },
  },
})
