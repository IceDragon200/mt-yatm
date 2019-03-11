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
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:server_rack_error",
    error = "yatm_machines:server_rack_error",
    off = "yatm_machines:server_rack_off",
    on = "yatm_machines:server_rack_on",
  },
  passive_energy_lost = 10
}

function server_rack_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm.devices.register_network_device(server_rack_yatm_network.states.off, {
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
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_rack_node_box,
  yatm_network = server_rack_yatm_network,
})

yatm.devices.register_network_device(server_rack_yatm_network.states.error, {
  description = "Server Rack",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = server_rack_yatm_network.states.off,
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
  yatm_network = server_rack_yatm_network,
})

yatm.devices.register_network_device(server_rack_yatm_network.states.on, {
  description = "Server Rack",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = server_rack_yatm_network.states.off,
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
  yatm_network = server_rack_yatm_network,
})
