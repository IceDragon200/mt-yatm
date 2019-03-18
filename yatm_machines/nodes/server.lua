local server_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
  },
  states = {
    conflict = "yatm_machines:server_error",
    error = "yatm_machines:server_error",
    off = "yatm_machines:server_off",
    on = "yatm_machines:server_on",
  },
  passive_energy_lost = 20
}

local server_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- InnerCore
    {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Rack4
    {-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- Rack3
    {-0.5, -0.1875, -0.5, 0.5, 0, 0.5}, -- Rack2
    {-0.5, -0.4375, -0.5, 0.5, -0.25, 0.5}, -- Rack1
    {-0.4375, -0.4375, 0.4375, 0.0625, 0.3125, 0.5}, -- BackPanel
  }
}

local groups = {
  cracky = 1,
  yatm_data_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_network_device(server_yatm_network.states.off, {
  description = "Server",
  groups = yatm_core.table_merge(groups),
  drop = server_yatm_network.states.off,
  tiles = {
    "yatm_server_top.off.png",
    "yatm_server_bottom.png",
    "yatm_server_side.png",
    "yatm_server_side.png^[transformFX",
    "yatm_server_back.off.png",
    "yatm_server_front.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = server_node_box,
  yatm_network = server_yatm_network,
})

yatm.devices.register_network_device(server_yatm_network.states.error, {
  description = "Server",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = server_yatm_network.states.off,
  tiles = {
    "yatm_server_top.error.png",
    "yatm_server_bottom.png",
    "yatm_server_side.png",
    "yatm_server_side.png^[transformFX",
    "yatm_server_back.error.png",
    "yatm_server_front.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = server_node_box,
  yatm_network = server_yatm_network,
})

yatm.devices.register_network_device(server_yatm_network.states.on, {
  description = "Server",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  drop = server_yatm_network.states.off,
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
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = server_node_box,
  yatm_network = server_yatm_network,
})
