local flat_monitor_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, 0.25, 0.5, 0.5, 0.5}, -- NodeBox1
  }
}

local monitor_console_yatm_network = {
  kind = "monitor",
  group = {monitor = 1},
  states = {
    error = "yatm_machines:flat_monitor_console_error",
    conflict = "yatm_machines:flat_monitor_console_error",
    off = "yatm_machines:flat_monitor_console_off",
    on = "yatm_machines:flat_monitor_console_on",
  },
}

yatm_machines.register_network_device("yatm_machines:flat_monitor_console_off", {
  description = "Flat Monitor (console)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.console.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_console_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_console_error", {
  description = "Flat Monitor (console)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.console.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_console_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_console_on", {
  description = "Flat Monitor (console)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
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
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

local monitor_crafting_yatm_network = {
  kind = "monitor",
  group = {monitor = 1},
  states = {
    error = "yatm_machines:flat_monitor_crafting_error",
    conflict = "yatm_machines:flat_monitor_crafting_error",
    off = "yatm_machines:flat_monitor_crafting_off",
    on = "yatm_machines:flat_monitor_crafting_on",
  },
}

yatm_machines.register_network_device("yatm_machines:flat_monitor_crafting_off", {
  description = "Flat Monitor (crafting)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_crafting_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_crafting_error", {
  description = "Flat Monitor (crafting)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_crafting_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_crafting_on", {
  description = "Flat Monitor (crafting)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_crafting_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

local monitor_ele_yatm_network = {
  kind = "monitor",
  group = {monitor = 1},
  states = {
    error = "yatm_machines:flat_monitor_ele_error",
    conflict = "yatm_machines:flat_monitor_ele_error",
    off = "yatm_machines:flat_monitor_ele_off",
    on = "yatm_machines:flat_monitor_ele_on",
  },
}

yatm_machines.register_network_device("yatm_machines:flat_monitor_ele_off", {
  description = "Flat Monitor (ele)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_ele_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_ele_error", {
  description = "Flat Monitor (ele)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_ele_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_ele_on", {
  description = "Flat Monitor (ele)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_ele_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

local monitor_inventory_yatm_network = {
  kind = "monitor",
  group = {monitor = 1},
  states = {
    error = "yatm_machines:flat_monitor_inventory_error",
    conflict = "yatm_machines:flat_monitor_inventory_error",
    off = "yatm_machines:flat_monitor_inventory_off",
    on = "yatm_machines:flat_monitor_inventory_on",
  },
}

yatm_machines.register_network_device("yatm_machines:flat_monitor_inventory_off", {
  description = "Flat Monitor (inventory)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_inventory_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_inventory_error", {
  description = "Flat Monitor (inventory)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_inventory_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})

yatm_machines.register_network_device("yatm_machines:flat_monitor_inventory_on", {
  description = "Flat Monitor (inventory)",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = monitor_inventory_yatm_network,
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,
})
