local flat_monitor_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, 0.25, 0.5, 0.5, 0.5}, -- NodeBox1
  }
}

local monitor_console_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    console_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:flat_monitor_console_error",
    conflict = "yatm_dscs:flat_monitor_console_error",
    off = "yatm_dscs:flat_monitor_console_off",
    on = "yatm_dscs:flat_monitor_console_on",
  },
  energy = {
    passive_lost = 10,
  },
}

local groups = {
  cracky = 1,
  monitor = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Flat Monitor (console)",
  groups = groups,

  drop = monitor_console_yatm_network.states.off,

  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.console.off.png",
  },
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = monitor_console_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.console.error.png",
    },
  },
  on = {
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
  }
})

local monitor_crafting_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    crafting_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:flat_monitor_crafting_error",
    conflict = "yatm_dscs:flat_monitor_crafting_error",
    off = "yatm_dscs:flat_monitor_crafting_off",
    on = "yatm_dscs:flat_monitor_crafting_on",
  },
  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Flat Monitor (crafting)",

  groups = groups,

  drop = monitor_crafting_yatm_network.states.off,

  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.off.png",
  },
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = monitor_crafting_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.crafting.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.crafting.on.png",
    },
  }
})

local monitor_ele_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    ele_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:flat_monitor_ele_error",
    conflict = "yatm_dscs:flat_monitor_ele_error",
    off = "yatm_dscs:flat_monitor_ele_off",
    on = "yatm_dscs:flat_monitor_ele_on",
  },
  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Flat Monitor (ele)",
  groups = groups,
  drop = monitor_ele_yatm_network.states.off,
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
}, {
  error = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.ele.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.ele.on.png",
    },
  },
})

local monitor_inventory_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    inventory_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_dscs:flat_monitor_inventory_error",
    conflict = "yatm_dscs:flat_monitor_inventory_error",
    off = "yatm_dscs:flat_monitor_inventory_off",
    on = "yatm_dscs:flat_monitor_inventory_on",
  },
  energy = {
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  description = "Flat Monitor (inventory)",

  groups = groups,

  drop = monitor_inventory_yatm_network.states.off,

  tiles = {
    "yatm_monitor_top.flat.png",
    "yatm_monitor_bottom.flat.png",
    "yatm_monitor_side.flat.png",
    "yatm_monitor_side.flat.png^[transformFX",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.off.png",
  },

  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = monitor_inventory_yatm_network,
}, {
  error = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.inventory.error.png",
    },
  },

  on = {
    tiles = {
      "yatm_monitor_top.flat.png",
      "yatm_monitor_bottom.flat.png",
      "yatm_monitor_side.flat.png",
      "yatm_monitor_side.flat.png^[transformFX",
      "yatm_monitor_back.png",
      "yatm_monitor_front.inventory.on.png",
    },
  },
})

