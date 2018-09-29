--[[



]]
local monitor_console_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    error = "yatm_machines:monitor_console_error",
    conflict = "yatm_machines:monitor_console_error",
    off = "yatm_machines:monitor_console_off",
    on = "yatm_machines:monitor_console_on",
  },
}

yatm_machines.register_network_device("yatm_machines:monitor_console_off", {
  description = "Monitor (console)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.console.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_console_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_console_error", {
  description = "Monitor (console)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.console.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_console_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_console_on", {
  description = "Monitor (console)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    {
      name = "yatm_monitor_front.console.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_console_yatm_network,
})

--[[



]]
local monitor_crafting_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    error = "yatm_machines:monitor_crafting_error",
    conflict = "yatm_machines:monitor_crafting_error",
    off = "yatm_machines:monitor_crafting_off",
    on = "yatm_machines:monitor_crafting_on",
  },
}

yatm_machines.register_network_device("yatm_machines:monitor_crafting_off", {
  description = "Monitor (crafting)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_crafting_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_crafting_error", {
  description = "Monitor (crafting)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_crafting_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_crafting_on", {
  description = "Monitor (crafting)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_crafting_yatm_network,
})

--[[



]]
local monitor_ele_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    error = "yatm_machines:monitor_ele_error",
    conflict = "yatm_machines:monitor_ele_error",
    off = "yatm_machines:monitor_ele_off",
    on = "yatm_machines:monitor_ele_on",
  },
}

yatm_machines.register_network_device("yatm_machines:monitor_ele_off", {
  description = "Monitor (ele)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_ele_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_ele_error", {
  description = "Monitor (ele)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_ele_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_ele_on", {
  description = "Monitor (ele)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_ele_yatm_network,
})

--[[



]]
local monitor_inventory_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    error = "yatm_machines:monitor_inventory_error",
    conflict = "yatm_machines:monitor_inventory_error",
    off = "yatm_machines:monitor_inventory_off",
    on = "yatm_machines:monitor_inventory_on",
  },
}

yatm_machines.register_network_device("yatm_machines:monitor_inventory_off", {
  description = "Monitor (inventory)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_inventory_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_inventory_error", {
  description = "Monitor (inventory)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_inventory_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:monitor_inventory_on", {
  description = "Monitor (inventory)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_inventory_yatm_network,
})
