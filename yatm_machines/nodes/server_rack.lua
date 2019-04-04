local server_rack_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
  }
}

local server_rack_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:server_rack_error",
    error = "yatm_machines:server_rack_error",
    off = "yatm_machines:server_rack_off",
    on = "yatm_machines:server_rack_on",
  },
  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Server Rack",

  groups = {cracky = 1},

  drop = server_rack_yatm_network.states.off,

  tiles = {
    "yatm_server_rack_top.off.png",
    "yatm_server_rack_bottom.png",
    "yatm_server_rack_side.off.png",
    "yatm_server_rack_side.off.png^[transformFX",
    "yatm_server_rack_back.off.png",
    "yatm_server_rack_front.off.png",
  },
  drawtype = "nodebox",
  node_box = server_rack_node_box,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = server_rack_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_server_rack_top.error.png",
      "yatm_server_rack_bottom.png",
      "yatm_server_rack_side.error.png",
      "yatm_server_rack_side.error.png^[transformFX",
      "yatm_server_rack_back.error.png",
      "yatm_server_rack_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_server_rack_top.on.png",
      "yatm_server_rack_bottom.png",
      "yatm_server_rack_side.on.png",
      "yatm_server_rack_side.on.png^[transformFX",
      "yatm_server_rack_back.on.png",
      {
        name = "yatm_server_rack_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      }
    },
  }
})
