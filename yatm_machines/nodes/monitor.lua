--[[

]]
local groups = {
  cracky = 1,
  monitor = 1,
  yatm_energy_device = 1,
  yatm_data_device = 1,
}

local monitor_console_yatm_network = {
  basename = "yatm_machines:monitor_console",
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:monitor_console_error",
    conflict = "yatm_machines:monitor_console_error",
    off = "yatm_machines:monitor_console_off",
    on = "yatm_machines:monitor_console_on",
  },
}

yatm.devices.register_network_device("yatm_machines:monitor_console_off", {
  description = "Monitor (console)",
  groups = yatm_core.table_merge(groups, {}),
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

yatm.devices.register_network_device("yatm_machines:monitor_console_error", {
  description = "Monitor (console)",
  drop = monitor_console_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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

yatm.devices.register_network_device("yatm_machines:monitor_console_on", {
  description = "Monitor (console)",
  drop = monitor_console_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
  basename = "yatm_machines:monitor_crafting",
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:monitor_crafting_error",
    conflict = "yatm_machines:monitor_crafting_error",
    off = "yatm_machines:monitor_crafting_off",
    on = "yatm_machines:monitor_crafting_on",
  },
}

yatm.devices.register_network_device("yatm_machines:monitor_crafting_off", {
  description = "Monitor (crafting)",
  groups = yatm_core.table_merge(groups, {}),
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

yatm.devices.register_network_device("yatm_machines:monitor_crafting_error", {
  description = "Monitor (crafting)",
  drop = monitor_crafting_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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

yatm.devices.register_network_device("yatm_machines:monitor_crafting_on", {
  description = "Monitor (crafting)",
  drop = monitor_crafting_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
  basename = "yatm_machines:monitor_ele",
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:monitor_ele_error",
    conflict = "yatm_machines:monitor_ele_error",
    off = "yatm_machines:monitor_ele_off",
    on = "yatm_machines:monitor_ele_on",
  },
}

yatm.devices.register_network_device("yatm_machines:monitor_ele_off", {
  description = "Monitor (ele)",
  drop = monitor_ele_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {}),
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

yatm.devices.register_network_device("yatm_machines:monitor_ele_error", {
  description = "Monitor (ele)",
  drop = monitor_ele_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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

yatm.devices.register_network_device("yatm_machines:monitor_ele_on", {
  description = "Monitor (ele)",
  drop = monitor_ele_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
  basename = "yatm_machines:monitor_inventory",
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
  },
  states = {
    error = "yatm_machines:monitor_inventory_error",
    conflict = "yatm_machines:monitor_inventory_error",
    off = "yatm_machines:monitor_inventory_off",
    on = "yatm_machines:monitor_inventory_on",
  },
}

yatm.devices.register_network_device("yatm_machines:monitor_inventory_off", {
  description = "Monitor (inventory)",
  groups = yatm_core.table_merge(groups, {}),
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

yatm.devices.register_network_device("yatm_machines:monitor_inventory_error", {
  description = "Monitor (inventory)",
  drop = monitor_inventory_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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

yatm.devices.register_network_device("yatm_machines:monitor_inventory_on", {
  description = "Monitor (inventory)",
  drop = monitor_inventory_yatm_network.basename .. "_off",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
