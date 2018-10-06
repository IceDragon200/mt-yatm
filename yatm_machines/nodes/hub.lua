local hub_nodebox = {
  type = "fixed",
  fixed = {
    {-0.375, -0.5, -0.375, 0.375, -0.25, 0.375},
  }
}

local hub_bus_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:hub_bus_error",
    conflict = "yatm_machines:hub_bus_error",
    off = "yatm_machines:hub_bus_off",
    on = "yatm_machines:hub_bus_on",
  },
}

yatm_machines.register_network_device("yatm_machines:hub_bus_off", {
  description = "Hub (bus)",
  groups = {cracky = 1},
  tiles = {
    "yatm_hub_top.off.png",
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
  yatm_network = hub_bus_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:hub_bus_error", {
  description = "Hub (bus)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.error.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.error.png",
    "yatm_hub_side.error.png^[transformFX",
    "yatm_hub_side.error.png",
    "yatm_hub_side.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
  yatm_network = hub_bus_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:hub_bus_on", {
  description = "Hub (bus)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.on.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png^[transformFX",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
  yatm_network = hub_bus_yatm_network,
})

local hub_wireless_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:hub_wireless_error",
    conflict = "yatm_machines:hub_wireless_error",
    off = "yatm_machines:hub_wireless_off",
    on = "yatm_machines:hub_wireless_on",
  },
}

yatm_machines.register_network_device("yatm_machines:hub_wireless_off", {
  description = "Hub (wireless)",
  groups = {cracky = 1},
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
  yatm_network = hub_wireless_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:hub_wireless_error", {
  description = "Hub (wireless)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.wireless.error.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.error.png",
    "yatm_hub_side.error.png^[transformFX",
    "yatm_hub_side.error.png",
    "yatm_hub_side.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
  yatm_network = hub_wireless_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:hub_wireless_on", {
  description = "Hub (wireless)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
  yatm_network = hub_wireless_yatm_network,
})

local hub_elegens_yatm_network = {
  kind = "hub",
  groups = {
    hub = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:hub_elegens_error",
    conflict = "yatm_machines:hub_elegens_error",
    off = "yatm_machines:hub_elegens_off",
    on = "yatm_machines:hub_elegens_on",
  },
}

yatm_machines.register_network_device("yatm_machines:hub_elegens_off", {
  description = "Hub (ele)",
  groups = {cracky = 1},
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
  yatm_network = hub_elegens_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:hub_elegens_error", {
  description = "Hub (ele)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.ele.error.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.error.png",
    "yatm_hub_side.error.png^[transformFX",
    "yatm_hub_side.error.png",
    "yatm_hub_side.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
  yatm_network = hub_elegens_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:hub_elegens_on", {
  description = "Hub (ele)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_hub_top.ele.on.png",
    "yatm_hub_bottom.png",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png^[transformFX",
    "yatm_hub_side.on.png",
    "yatm_hub_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = hub_nodebox,
  yatm_network = hub_elegens_yatm_network,
})
