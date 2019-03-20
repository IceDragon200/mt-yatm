local thermal_plate_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (3.0 / 16.0) - 0.5, 0.5},
  }
}

local function thermal_plate_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm_core.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm.devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
end

local thermal_plate_heating_yatm_network = {
  kind = "thermal_plate",
  groups = {
    thermal_plate = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:thermal_plate_heating_error",
    conflict = "yatm_machines:thermal_plate_heating_error",
    off = "yatm_machines:thermal_plate_heating_off",
    on = "yatm_machines:thermal_plate_heating_on",
  },
  energy = {
    passive_lost = 1,
  },
}

local thermal_plate_side_on_texture = {
  name = "yatm_thermal_plate_side.heating.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm.devices.register_stateful_network_device({
  description = "Thermal Plate (heating)",

  groups = {cracky = 1},

  drop = thermal_plate_heating_yatm_network.states.off,

  tiles = { "yatm_thermal_plate_side.heating.off.png" },
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_heating_yatm_network,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.heating.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  },
})

local thermal_plate_cooling_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:thermal_plate_cooling_error",
    conflict = "yatm_machines:thermal_plate_cooling_error",
    off = "yatm_machines:thermal_plate_cooling_off",
    on = "yatm_machines:thermal_plate_cooling_on",
  },
  energy = {
    passive_lost = 1,
  },
}

local thermal_plate_side_on_texture = {
  name = "yatm_thermal_plate_side.cooling.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm.devices.register_stateful_network_device({
  description = "Thermal Plate (cooling)",

  groups = {cracky = 1},

  drop = thermal_plate_cooling_yatm_network.states.off,

  tiles = {
    "yatm_thermal_plate_side.cooling.off.png",
  },
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_cooling_yatm_network,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.cooling.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  },
})

yatm.devices.register_network_device(thermal_plate_cooling_yatm_network.states.error, {
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

--[[
Nuclear
]]
local thermal_plate_nuclear_yatm_network = {
  kind = "thermal_plate",

  groups = {
    thermal_plate = 1,
    nuclear_plate = 1,
    energy_consumer = 1,
  },

  default_state = "off",
  states = {
    error = "yatm_machines:thermal_plate_nuclear_error",
    conflict = "yatm_machines:thermal_plate_nuclear_error",
    off = "yatm_machines:thermal_plate_nuclear_off",
    on = "yatm_machines:thermal_plate_nuclear_on",
  },

  energy = {
    passive_lost = 1,
  },
}

local thermal_plate_side_on_texture = {
  name = "yatm_thermal_plate_side.nuclear.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.0
  },
}

yatm.devices.register_stateful_network_device({
  description = "Thermal Plate (nuclear)",

  groups = {cracky = 1, nuclear_plate = 1},

  drop = thermal_plate_nuclear_yatm_network.states.off,

  tiles = {
    "yatm_thermal_plate_side.nuclear.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,
  after_place_node = thermal_plate_after_place_node,
  yatm_network = thermal_plate_nuclear_yatm_network,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.nuclear.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  }
})
