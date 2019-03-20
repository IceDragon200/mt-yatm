--[[
Servers provide a means to automate certain tasks in a network (i.e. crafting)
]]
local server_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:server_error",
    error = "yatm_machines:server_error",
    off = "yatm_machines:server_off",
    on = "yatm_machines:server_on",
  },
  energy = {
    passive_lost = 20,
  }
}

yatm.devices.register_stateful_network_device({
  description = "Server",

  groups = {
    cracky = 1,
    yatm_data_device = 1,
    yatm_energy_device = 1,
  },

  drop = server_yatm_network.states.off,

  tiles = {
    "yatm_server_top.off.png",
    "yatm_server_bottom.png",
    "yatm_server_side.png",
    "yatm_server_side.png^[transformFX",
    "yatm_server_back.off.png",
    "yatm_server_front.off.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- InnerCore
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Rack4
      {-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- Rack3
      {-0.5, -0.1875, -0.5, 0.5, 0, 0.5}, -- Rack2
      {-0.5, -0.4375, -0.5, 0.5, -0.25, 0.5}, -- Rack1
      {-0.4375, -0.4375, 0.4375, 0.0625, 0.3125, 0.5}, -- BackPanel
    }
  },

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = server_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_server_top.error.png",
      "yatm_server_bottom.png",
      "yatm_server_side.png",
      "yatm_server_side.png^[transformFX",
      "yatm_server_back.error.png",
      "yatm_server_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_server_top.on.png",
      "yatm_server_bottom.png",
      "yatm_server_side.png",
      "yatm_server_side.png^[transformFX",
      -- "yatm_server_back.off.png",
      {
        name = "yatm_server_back.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      -- "yatm_server_front.off.png"
      {
        name = "yatm_server_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      }
    },
  }
})
