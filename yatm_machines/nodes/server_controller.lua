local server_controller_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
  }
}

local server_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:server_controller_error",
    error = "yatm_machines:server_controller_error",
    off = "yatm_machines:server_controller_off",
    on = "yatm_machines:server_controller_on",
  },
  passive_energy_consume = 5
}

function server_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm_machines.register_network_device("yatm_machines:server_controller_off", {
  description = "Server Controller",
  groups = {cracky = 1},
  tiles = {
    "yatm_server_controller_top.off.png",
    "yatm_server_controller_bottom.png",
    "yatm_server_controller_side.off.png",
    "yatm_server_controller_side.off.png^[transformFX",
    "yatm_server_controller_back.off.png",
    "yatm_server_controller_front.off.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_controller_node_box,
  yatm_network = server_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:server_controller_error", {
  description = "Server Controller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_server_controller_top.error.png",
    "yatm_server_controller_bottom.png",
    "yatm_server_controller_side.error.png",
    "yatm_server_controller_side.error.png^[transformFX",
    "yatm_server_controller_back.error.png",
    "yatm_server_controller_front.error.png",
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_controller_node_box,
  yatm_network = server_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:server_controller_on", {
  description = "Server Controller",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  node_box = server_controller_node_box,
  yatm_network = server_yatm_network,
})
