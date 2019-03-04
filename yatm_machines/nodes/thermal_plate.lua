local thermal_plate_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (3.0 / 16.0) - 0.5, 0.5},
  }
}

local function thermal_plate_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm_core.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm_machines.device_after_place_node(pos, placer, item_stack, pointed_thing)
end

local thermal_plate_heating_yatm_network = {
  kind = "thermal_plate",
  groups = {
    thermal_plate = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:thermal_plate_heating_error",
    conflict = "yatm_machines:thermal_plate_heating_error",
    off = "yatm_machines:thermal_plate_heating_off",
    on = "yatm_machines:thermal_plate_heating_on",
  },
}

yatm_machines.register_network_device(thermal_plate_heating_yatm_network.states.off, {
  description = "Thermal Plate (heating)",
  groups = {cracky = 1},
  drop = thermal_plate_heating_yatm_network.states.off,
  tiles = {
    --[["yatm_thermal_plate_top.heating.off.png",
    "yatm_thermal_plate_top.heating.off.png",
    "yatm_thermal_plate_side.heating.off.png",
    "yatm_thermal_plate_side.heating.off.png",
    "yatm_thermal_plate_side.heating.off.png",]]
    "yatm_thermal_plate_side.heating.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_heating_yatm_network,
})

yatm_machines.register_network_device(thermal_plate_heating_yatm_network.states.error, {
  description = "Thermal Plate (heating)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = thermal_plate_heating_yatm_network.states.off,
  tiles = {
    --[["yatm_thermal_plate_top.heating.error.png",
    "yatm_thermal_plate_top.heating.error.png",
    "yatm_thermal_plate_side.heating.error.png",
    "yatm_thermal_plate_side.heating.error.png",
    "yatm_thermal_plate_side.heating.error.png",]]
    "yatm_thermal_plate_side.heating.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_heating_yatm_network,
})

local thermal_plate_top_texture = {
  name = "yatm_thermal_plate_top.heating.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

local thermal_plate_side_texture = {
  name = "yatm_thermal_plate_side.heating.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm_machines.register_network_device(thermal_plate_heating_yatm_network.states.on, {
  description = "Thermal Plate (heating)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = thermal_plate_heating_yatm_network.states.off,
  tiles = {
    --[[thermal_plate_top_texture,
    thermal_plate_top_texture,
    thermal_plate_side_texture,
    thermal_plate_side_texture,
    thermal_plate_side_texture,]]
    thermal_plate_side_texture,
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_heating_yatm_network,
})

local thermal_plate_cooling_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:thermal_plate_cooling_error",
    conflict = "yatm_machines:thermal_plate_cooling_error",
    off = "yatm_machines:thermal_plate_cooling_off",
    on = "yatm_machines:thermal_plate_cooling_on",
  },
}

yatm_machines.register_network_device(thermal_plate_cooling_yatm_network.states.off, {
  description = "Thermal Plate (cooling)",
  groups = {cracky = 1},
  drop = thermal_plate_cooling_yatm_network.states.off,
  tiles = {
    --[["yatm_thermal_plate_top.cooling.off.png",
    "yatm_thermal_plate_top.cooling.off.png",
    "yatm_thermal_plate_side.cooling.off.png",
    "yatm_thermal_plate_side.cooling.off.png",
    "yatm_thermal_plate_side.cooling.off.png",]]
    "yatm_thermal_plate_side.cooling.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_cooling_yatm_network,
})

yatm_machines.register_network_device(thermal_plate_cooling_yatm_network.states.error, {
  description = "Thermal Plate (cooling)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = thermal_plate_cooling_yatm_network.states.off,
  tiles = {
    --[["yatm_thermal_plate_top.cooling.error.png",
    "yatm_thermal_plate_top.cooling.error.png",
    "yatm_thermal_plate_side.cooling.error.png",
    "yatm_thermal_plate_side.cooling.error.png",
    "yatm_thermal_plate_side.cooling.error.png",]]
    "yatm_thermal_plate_side.cooling.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_cooling_yatm_network,
})

local thermal_plate_top_texture = {
  name = "yatm_thermal_plate_top.cooling.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

local thermal_plate_side_texture = {
  name = "yatm_thermal_plate_side.cooling.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm_machines.register_network_device(thermal_plate_cooling_yatm_network.states.on, {
  description = "Thermal Plate (cooling)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = thermal_plate_cooling_yatm_network.states.off,
  tiles = {
    --[[thermal_plate_top_texture,
    thermal_plate_top_texture,
    thermal_plate_side_texture,
    thermal_plate_side_texture,
    thermal_plate_side_texture,]]
    thermal_plate_side_texture,
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_cooling_yatm_network,
})
