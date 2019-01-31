local pylon_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:pylon_error",
    error = "yatm_machines:pylon_error",
    off = "yatm_machines:pylon_off",
    on = "yatm_machines:pylon_on",
  }
}

function pylon_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

local pylon_side_animation = {
  name = "yatm_pylon_side.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1
  },
}

local pylon_node_box = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375},
    {-0.4375, -0.5, -0.1875, 0.4375, -0.125, 0.1875},
    {-0.1875, -0.5, -0.4375, 0.1875, -0.125, 0.4375},
  }
}

yatm_machines.register_network_device("yatm_machines:pylon_off", {
  description = "Pylon",
  groups = {cracky = 1},
  tiles = {
    "yatm_pylon_top.off.png",
    "yatm_pylon_bottom.off.png",
    "yatm_pylon_side.off.png",
    "yatm_pylon_side.off.png",
    "yatm_pylon_side.off.png",
    "yatm_pylon_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = pylon_node_box,
  yatm_network = pylon_yatm_network
})

yatm_machines.register_network_device("yatm_machines:pylon_error", {
  description = "Pylon",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    {
      name = "yatm_pylon_top.error.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1
      },
    },
    {
      name = "yatm_pylon_bottom.error.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1
      },
    },
    "yatm_pylon_side.error.png",
    "yatm_pylon_side.error.png",
    "yatm_pylon_side.error.png",
    "yatm_pylon_side.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = pylon_node_box,
  yatm_network = pylon_yatm_network
})

yatm_machines.register_network_device("yatm_machines:pylon_on", {
  description = "Pylon",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    {
      name = "yatm_pylon_top.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1
      },
    },
    {
      name = "yatm_pylon_bottom.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1
      },
    },
    pylon_side_animation,
    pylon_side_animation,
    pylon_side_animation,
    pylon_side_animation,
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = pylon_node_box,
  yatm_network = pylon_yatm_network
})

