dofile(yatm_machines.modpath .. "/nodes/auto_crafter.lua")
dofile(yatm_machines.modpath .. "/nodes/auto_grinder.lua")
dofile(yatm_machines.modpath .. "/nodes/coal_generator.lua")
dofile(yatm_machines.modpath .. "/nodes/battery_bank.lua")
dofile(yatm_machines.modpath .. "/nodes/compactor.lua")
dofile(yatm_machines.modpath .. "/nodes/crusher.lua")
dofile(yatm_machines.modpath .. "/nodes/drive_case.lua")
dofile(yatm_machines.modpath .. "/nodes/energy_cells.lua")
dofile(yatm_machines.modpath .. "/nodes/crystal_cauldron.lua")
dofile(yatm_machines.modpath .. "/nodes/hub.lua")
dofile(yatm_machines.modpath .. "/nodes/void_crate.lua")
dofile(yatm_machines.modpath .. "/nodes/fluid_replicator.lua")

minetest.register_node("yatm_machines:electrolyser", {
  description = "Electrolyser",
  groups = {cracky = 1},
  tiles = {
    "yatm_electrolyser_top.on.png",
    "yatm_electrolyser_bottom.png",
    "yatm_electrolyser_side.on.png",
    "yatm_electrolyser_side.on.png",
    "yatm_electrolyser_back.png",
    --"yatm_electrolyser_front.off.png"
    {
      name = "yatm_electrolyser_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:flux_furnace", {
  description = "Flux Furnace",
  groups = {cracky = 1},
  tiles = {
    "yatm_flux_furnace_top.on.png",
    "yatm_flux_furnace_bottom.png",
    "yatm_flux_furnace_side.on.png",
    "yatm_flux_furnace_side.on.png",
    "yatm_flux_furnace_back.png",
    "yatm_flux_furnace_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:heater", {
  description = "Heater",
  groups = {cracky = 1},
  tiles = {
    "yatm_heater_top.on.png",
    "yatm_heater_bottom.png",
    "yatm_heater_side.on.png",
    "yatm_heater_side.on.png",
    "yatm_heater_back.on.png",
    "yatm_heater_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:item_replicator", {
  description = "Item Replicator",
  groups = {cracky = 1},
  tiles = {
    "yatm_item_replicator_top.on.png",
    "yatm_item_replicator_bottom.png",
    "yatm_item_replicator_side.on.png",
    "yatm_item_replicator_side.on.png",
    -- "yatm_item_replicator_back.off.png",
    {
      name = "yatm_item_replicator_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    -- "yatm_item_replicator_front.off.png"
    {
      name = "yatm_item_replicator_front.on.png",
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
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:mixer", {
  description = "Mixer",
  groups = {cracky = 1},
  tiles = {
    "yatm_mixer_top.on.png",
    "yatm_mixer_bottom.png",
    "yatm_mixer_side.on.png",
    "yatm_mixer_side.on.png",
    "yatm_mixer_back.png",
    -- "yatm_mixer_front.off.png"
    {
      name = "yatm_mixer_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_console_off", {
  description = "Monitor (console) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.console.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_console_on", {
  description = "Monitor (console)",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
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
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_crafting_off", {
  description = "Monitor (crafting) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_crafting_on", {
  description = "Monitor (crafting) [on]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.crafting.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_ele_off", {
  description = "Monitor (ele) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_ele_on", {
  description = "Monitor (ele) [on]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.ele.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_inventory_off", {
  description = "Monitor (inventory) [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:monitor_inventory_on", {
  description = "Monitor (inventory) [on]",
  groups = {cracky = 1},
  tiles = {
    "yatm_monitor_top.png",
    "yatm_monitor_bottom.png",
    "yatm_monitor_side.png",
    "yatm_monitor_side.png",
    "yatm_monitor_back.png",
    "yatm_monitor_front.inventory.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

local pylon_side_animation = {
  name = "yatm_pylon_side.on.png",
  animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1
  },
}

minetest.register_node("yatm_machines:pylon", {
  description = "Pylon",
  groups = {cracky = 1},
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
  legacy_facedir_simple = true,
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375},
      {-0.4375, -0.5, -0.1875, 0.4375, -0.125, 0.1875},
      {-0.1875, -0.5, -0.4375, 0.1875, -0.125, 0.4375},
    }
  }
})

minetest.register_node("yatm_machines:roller", {
  description = "Roller",
  groups = {cracky = 1},
  tiles = {
    "yatm_roller_top.on.png",
    "yatm_roller_bottom.png",
    "yatm_roller_side.on.png",
    "yatm_roller_side.on.png",
    "yatm_roller_back.png",
    --"yatm_roller_front.off.png"
    {
      name = "yatm_roller_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:server", {
  description = "Server",
  groups = {cracky = 1},
  tiles = {
    "yatm_server_top.png",
    "yatm_server_bottom.png",
    "yatm_server_side.png",
    "yatm_server_side.png",
    -- "yatm_server_back.off.png",
    {
      name = "yatm_server_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 2.0
      },
    },
    -- "yatm_server_front.off.png"
    {
      name = "yatm_server_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- InnerCore
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Rack4
      {-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- Rack3
      {-0.5, -0.1875, -0.5, 0.5, 0, 0.5}, -- Rack2
      {-0.5, -0.4375, -0.5, 0.5, -0.25, 0.5}, -- Rack1
      {-0.4375, -0.4375, 0.4375, 0.0625, 0.3125, 0.5}, -- BackPanel
    }
  }
})

minetest.register_node("yatm_machines:server_rack", {
  description = "Server Rack",
  groups = {cracky = 1},
  tiles = {
    "yatm_server_rack_top.png",
    "yatm_server_rack_bottom.png",
    "yatm_server_rack_side.on.png",
    "yatm_server_rack_side.on.png",
    "yatm_server_rack_back.on.png",
    -- "yatm_server_rack_front.off.png"
    {
      name = "yatm_server_rack_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }
  },
  drawtype = "nodebox",
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
    }
  }
})

minetest.register_node("yatm_machines:wireless_emitter", {
  description = "Wireless Emitter",
  groups = {cracky = 1},
  tiles = {
    "yatm_wireless_emitter_top.on.png",
    "yatm_wireless_emitter_bottom.png",
    "yatm_wireless_emitter_side.on.png",
    "yatm_wireless_emitter_side.on.png",
    {
      name = "yatm_wireless_emitter_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    {
      name = "yatm_wireless_emitter_front.on.png",
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
  legacy_facedir_simple = true,
})

minetest.register_node("yatm_machines:wireless_receiver", {
  description = "Wireless Receiver",
  groups = {cracky = 1},
  tiles = {
    "yatm_wireless_receiver_top.on.png",
    "yatm_wireless_receiver_bottom.png",
    "yatm_wireless_receiver_side.on.png",
    "yatm_wireless_receiver_side.on.png",
    --"yatm_wireless_receiver_back.on.png",
    {
      name = "yatm_wireless_receiver_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    },
    -- "yatm_wireless_receiver_front.off.png",
    {
      name = "yatm_wireless_receiver_front.on.png",
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
  legacy_facedir_simple = true,
})
