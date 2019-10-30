local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function hub_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local hub_nodebox = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, (3 / 16.0) - 0.5, 0.375},
  }
}

local function hub_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm_core.facedir_wallmount_after_place_node(pos, placer, item_stack, pointed_thing)
  yatm.devices.device_after_place_node(pos, placer, item_stack, pointed_thing)
end

local hub_bus_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:hub_bus_error",
    conflict = "yatm_machines:hub_bus_error",
    off = "yatm_machines:hub_bus_off",
    on = "yatm_machines:hub_bus_on",
  },
  energy = {
    capacity = 200,
    passive_lost = 1,
    network_charge_bandwidth = 10,
    startup_threshold = 20,
  }
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:hub_bus",

  description = "Hub (bus)",

  groups = {cracky = 1},

  drop = hub_bus_yatm_network.states.off,

  tiles = {
    "yatm_hub_top.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png^[transformFX",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  drawtype = "nodebox",
  node_box = hub_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  after_place_node = hub_after_place_node,

  yatm_network = hub_bus_yatm_network,

  refresh_infotext = hub_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_hub_top.error.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png^[transformFX",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_hub_top.on.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png^[transformFX",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png",
    },
  },
})

local hub_wireless_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:hub_wireless_error",
    conflict = "yatm_machines:hub_wireless_error",
    off = "yatm_machines:hub_wireless_off",
    on = "yatm_machines:hub_wireless_on",
  },
  energy = {
    passive_lost = 1,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:hub_wireless",

  description = "Hub (wireless)",
  groups = {cracky = 1},
  drop = hub_wireless_yatm_network.states.off,

  tiles = {
    "yatm_hub_top.wireless.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png^[transformFX",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,

  after_place_node = hub_after_place_node,

  yatm_network = hub_wireless_yatm_network,

  refresh_infotext = hub_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_hub_top.wireless.error.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png^[transformFX",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_hub_top.wireless.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_hub_bottom.png",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png^[transformFX",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png",
    },
  }
})

local hub_elegens_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_machines:hub_elegens_error",
    conflict = "yatm_machines:hub_elegens_error",
    off = "yatm_machines:hub_elegens_off",
    on = "yatm_machines:hub_elegens_on",
  },
  energy = {
    passive_lost = 1,
  },
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:hub_ele",

  description = "Hub (ele)",
  groups = {cracky = 1},
  drop = hub_elegens_yatm_network.states.off,
  tiles = {
    "yatm_hub_top.ele.off.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png^[transformFX",
    "yatm_hub_side.off.png",
    "yatm_hub_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,

  after_place_node = hub_after_place_node,

  yatm_network = hub_elegens_yatm_network,

  refresh_infotext = hub_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_hub_top.ele.error.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png^[transformFX",
      "yatm_hub_side.error.png",
      "yatm_hub_side.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_hub_top.ele.on.png",
      "yatm_hub_bottom.png",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png^[transformFX",
      "yatm_hub_side.on.png",
      "yatm_hub_side.on.png",
    },
  },
})
