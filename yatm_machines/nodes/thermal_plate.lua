local Directions = assert(foundation.com.Directions)
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function thermal_plate_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local thermal_plate_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (3.0 / 16.0) - 0.5, 0.5},
  }
}

local function thermal_plate_after_place_node(pos, placer, item_stack, pointed_thing)
  Directions.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
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
  basename = "yatm_machines:thermal_plate_heating",

  description = "Thermal Plate (heating)",

  groups = {cracky = 1},

  drop = thermal_plate_heating_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = { "yatm_thermal_plate_side.heating.off.png" },
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_heating_yatm_network,

  refresh_infotext = thermal_plate_refresh_infotext,
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
  basename = "yatm_machines:thermal_plate_cooling",

  description = "Thermal Plate (cooling)",

  groups = {cracky = 1},

  drop = thermal_plate_cooling_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_thermal_plate_side.cooling.off.png",
  },
  drawtype = "nodebox",
  node_box = thermal_plate_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_cooling_yatm_network,

  refresh_infotext = thermal_plate_refresh_infotext,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.cooling.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  },
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
  basename = "yatm_machines:thermal_plate_nuclear",

  description = "Thermal Plate (nuclear)",

  groups = {cracky = 1, nuclear_plate = 1},

  drop = thermal_plate_nuclear_yatm_network.states.off,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_thermal_plate_side.nuclear.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",

  node_box = thermal_plate_nodebox,

  after_place_node = thermal_plate_after_place_node,

  yatm_network = thermal_plate_nuclear_yatm_network,

  refresh_infotext = thermal_plate_refresh_infotext,
}, {
  error = {
    tiles = { "yatm_thermal_plate_side.nuclear.error.png" },
  },
  on = {
    tiles = { thermal_plate_side_on_texture },
  }
})
