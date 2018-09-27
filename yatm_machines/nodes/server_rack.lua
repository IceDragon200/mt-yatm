local server_rack_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
  }
}

local server_yatm_network = {
  kind = "machine",
  group = {machine = 1},
  states = {
    conflict = "yatm_machines:server_rack_error",
    error = "yatm_machines:server_rack_error",
    off = "yatm_machines:server_rack_off",
    on = "yatm_machines:server_rack_on",
  }
}

yatm_machines.register_network_device("yatm_machines:server_rack_off", {
  description = "Server Rack",
  groups = {cracky = 1},
  tiles = {
    "yatm_server_rack_top.off.png",
    "yatm_server_rack_bottom.png",
    "yatm_server_rack_side.off.png",
    "yatm_server_rack_side.off.png^[transformFX",
    "yatm_server_rack_back.off.png",
    "yatm_server_rack_front.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_rack_node_box,
  yatm_network = server_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:server_rack_error", {
  description = "Server Rack",
  groups = {cracky = 1},
  tiles = {
    "yatm_server_rack_top.error.png",
    "yatm_server_rack_bottom.png",
    "yatm_server_rack_side.error.png",
    "yatm_server_rack_side.error.png^[transformFX",
    "yatm_server_rack_back.error.png",
    "yatm_server_rack_front.error.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_rack_node_box,
  yatm_network = server_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:server_rack_on", {
  description = "Server Rack",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
        length = 1.0
      },
    }
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_rack_node_box,
  yatm_network = server_yatm_network,
})
