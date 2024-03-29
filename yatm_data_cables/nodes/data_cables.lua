--
--
--
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)
local list_concat = assert(foundation.com.list_concat)
local Directions = assert(foundation.com.Directions)

local data_network = assert(yatm.data_network)

local function data_cable_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext = data_network:get_infotext(pos)
  meta:set_string("infotext", infotext)
end

local function data_cable_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  data_network:add_node(pos, node)
  yatm.queue_refresh_infotext(pos, node)
end

local function data_cable_bracket_after_place_node(pos, placer, itemstack, pointed_thing)
  Directions.facedir_wallmount_after_place_node(pos, placer, itemstack, pointed_thing)
  data_cable_after_place_node(pos, placer, itemstack, pointed_thing)
end

local function data_cable_on_destruct(pos)
  print("data_cable_on_destruct", minetest.pos_to_string(pos))
end

local function data_cable_after_destruct(pos, old_node)
  print("data_cable_after_destruct", minetest.pos_to_string(pos))
  data_network:unregister_member(pos, old_node)
end

local data_cable_nodebox = {
  type = "connected",
  fixed          = ng(5, 0, 5, 6, 2, 6),
  connect_top    = ng(5, 2, 5, 6,14, 6), -- y+
  connect_bottom = ng(0, 0, 0, 0, 0, 0), -- y-
  connect_front  = ng(5, 0, 0, 6, 2, 5), -- z-
  connect_back   = ng(5, 0,11, 6, 2, 5), -- z+
  connect_left   = ng(0, 0, 5, 5, 2, 6), -- x-
  connect_right  = ng(11,0, 5, 5, 2, 6), -- x+
}

local data_bus_nodebox = {
  type = "connected",
  fixed          = ng(4, 0, 4, 8, 4, 8),
  connect_top    = ng(5, 4, 5, 6,12, 6), -- y+
  connect_bottom = ng(3, 0, 3,10, 1,10), -- y-
  connect_front  = ng(5, 0, 0, 6, 2, 4), -- z-
  connect_back   = ng(5, 0,12, 6, 2, 4), -- z+
  connect_left   = ng(0, 0, 5, 4, 2, 6), -- x-
  connect_right  = ng(12,0, 5, 4, 2, 6), -- x+
}

local straight_bracket_cable_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 5, 0, 0, 6, 2,16),
    ng( 4, 0, 1, 8, 3, 2),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local corner_bracket_cable_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 5, 0, 5, 6, 2,11),
    ng(11, 0, 5, 5, 2, 6),
    ng(13, 0, 4, 2, 3, 8),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local tee_bracket_cable_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 0, 0, 5,16, 2, 6),
    ng( 5, 0,11, 6, 2, 5),

    ng(13, 0, 4, 2, 3, 8),
    ng( 1, 0, 4, 2, 3, 8),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local cross_bracket_cable_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 5, 0, 0, 6, 2,16),
    ng( 0, 0, 5,16, 2, 6),
    ng(13, 0, 4, 2, 3, 8),
    ng( 1, 0, 4, 2, 3, 8),
    ng( 4, 0, 1, 8, 3, 2),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local bus_cube = ng( 4, 0, 4, 8, 4, 8) -- Bus Box
local straight_bracket_bus_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 5, 0, 0, 6, 2,16),
    bus_cube,
    --
    ng( 4, 0, 1, 8, 3, 2),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local corner_bracket_bus_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 5, 0, 5, 6, 2,11),
    bus_cube,

    ng(11, 0, 5, 5, 2, 6),
    ng(13, 0, 4, 2, 3, 8),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local tee_bracket_bus_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 0, 0, 5,16, 2, 6),
    ng( 5, 0,11, 6, 2, 5),
    bus_cube,

    ng(13, 0, 4, 2, 3, 8),
    ng( 1, 0, 4, 2, 3, 8),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local cross_bracket_bus_nodebox = {
  type = "fixed",
  fixed          = {
    ng( 5, 0, 0, 6, 2,16),
    ng( 0, 0, 5,16, 2, 6),
    bus_cube,

    ng(13, 0, 4, 2, 3, 8),
    ng( 1, 0, 4, 2, 3, 8),
    ng( 4, 0, 1, 8, 3, 2),
    ng( 4, 0,13, 8, 3, 2),
  }
}

local riser_bracket_cable_nodebox = {
  type = "fixed",
  fixed = {
    ng( 5, 0, 0, 6, 2,16),

    ng( 5, 0,14, 6,16, 2),
    ng( 4, 2,13, 8, 2, 3),
    ng( 4,13,13, 8, 2, 3),
  },
}

local function on_rotate(pos, node, user, mode, new_param2)
  print("Rotating cable " .. node.name)
  if node.param2 ~= new_param2 then
    local new_node = { name = node.name,
                       param1 = node.param1,
                       param2 = new_param2 }
    minetest.swap_node(pos, new_node)
    data_network:upsert_member(pos, new_node, true)
    minetest.check_for_falling(pos)
  end
  return true
end

local colors = list_concat({{name = "multi", description = "Multi"}}, yatm.colors)
local cables_to_migrate = {}
for _,row in ipairs(colors) do
  local color_basename = row.name
  local color_name = row.description

  local node_name = "yatm_data_cables:data_cable_bracket_straight_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bracket_straight_"..color_basename)

  local colored_group_name = "data_cable_bracket_straight_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable = 1,
    data_cable_bracket_straight = 1,
    ["data_cable_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  -- Mounteded Cables can be mounted on walls
  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bracket_straight",
    base_description = "Data Cable Mounted Straight",

    description = "Data Cable Mounted Straight (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = straight_bracket_cable_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_cable",
      accessible_dirs = {
        [Directions.D_NORTH] = true,
        [Directions.D_SOUTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bracket_corner_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bracket_corner_"..color_basename)

  local colored_group_name = "data_cable_bracket_corner_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable = 1,
    data_cable_bracket_corner = 1,
    ["data_cable_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bracket_corner",
    base_description = "Data Cable Mounted Corner",

    description = "Data Cable Mounted Corner (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = corner_bracket_cable_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_cable",
      accessible_dirs = {
        [Directions.D_EAST] = true,
        [Directions.D_NORTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bracket_tee_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bracket_tee_"..color_basename)

  local colored_group_name = "data_cable_bracket_tee_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable = 1,
    data_cable_bracket_tee = 1,
    ["data_cable_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bracket_tee",
    base_description = "Data Cable Mounted Tee",

    description = "Data Cable Mounted Tee (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = tee_bracket_cable_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_cable",
      accessible_dirs = {
        [Directions.D_WEST] = true,
        [Directions.D_EAST] = true,
        [Directions.D_NORTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bracket_cross_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bracket_cross_"..color_basename)

  local colored_group_name = "data_cable_bracket_cross_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable = 1,
    data_cable_bracket_cross = 1,
    ["data_cable_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bracket_cross",
    base_description = "Data Cable Mounted Cross",

    description = "Data Cable Mounted Cross (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = cross_bracket_cable_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_cable",
      accessible_dirs = {
        [Directions.D_WEST] = true,
        [Directions.D_EAST] = true,
        [Directions.D_NORTH] = true,
        [Directions.D_SOUTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bracket_riser_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bracket_riser_"..color_basename)

  local colored_group_name = "data_cable_bracket_riser_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable = 1,
    data_cable_bracket_riser = 1,
    ["data_cable_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bracket_riser",
    base_description = "Data Cable Mounted Riser",

    description = "Data Cable Mounted Riser (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".riser.front.png^yatm_data_cable_bracket.riser.top.png",
      "yatm_data_cable_" .. color_basename .. ".riser.front.png^yatm_data_cable_bracket.riser.top.png",
      "yatm_data_cable_" .. color_basename .. ".riser.side.png^yatm_data_cable_bracket.riser.side.png",
      "yatm_data_cable_" .. color_basename .. ".riser.side.png^yatm_data_cable_bracket.riser.side.png^[transformFX",
      "yatm_data_cable_" .. color_basename .. ".riser.front.png^yatm_data_cable_bracket.riser.front.png",
      "yatm_data_cable_" .. color_basename .. ".riser.front.png^yatm_data_cable_bracket.riser.front.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = riser_bracket_cable_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_cable",
      accessible_dirs = {
        [Directions.D_UP] = true,
        [Directions.D_SOUTH] = true,
      }
    },

    after_place_node = data_cable_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bus_bracket_straight_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bus_bracket_straight_"..color_basename)

  local colored_group_name = "data_cable_bus_bracket_straight_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable_bus = 1,
    data_cable_bus_bracket_straight = 1,
    ["data_cable_bus_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  -- Mounteded Buses can be mounted on walls
  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bus_bracket_straight",
    base_description = "Data Cable Bus Mounted Straight",

    description = "Data Cable Bus Mounted Straight (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable_bus",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = straight_bracket_bus_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_bus",
      accessible_dirs = {
        [Directions.D_NORTH] = true,
        [Directions.D_SOUTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bus_bracket_corner_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bus_bracket_corner_"..color_basename)

  local colored_group_name = "data_cable_bus_bracket_corner_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable_bus = 1,
    data_cable_bus_bracket_corner = 1,
    ["data_cable_bus_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bus_bracket_corner",
    base_description = "Data Cable Bus Mounted Corner",

    description = "Data Cable Bus Mounted Corner (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable_bus",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = corner_bracket_bus_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_bus",
      accessible_dirs = {
        [Directions.D_EAST] = true,
        [Directions.D_NORTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bus_bracket_tee_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bus_bracket_tee_"..color_basename)

  local colored_group_name = "data_cable_bus_bracket_tee_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable_bus = 1,
    data_cable_bus_bracket_tee = 1,
    ["data_cable_bus_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bus_bracket_tee",
    base_description = "Data Cable Bus Mounted Tee",

    description = "Data Cable Bus Mounted Tee (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable_bus",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = tee_bracket_bus_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_bus",
      accessible_dirs = {
        [Directions.D_WEST] = true,
        [Directions.D_EAST] = true,
        [Directions.D_NORTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local node_name = "yatm_data_cables:data_cable_bus_bracket_cross_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bus_bracket_cross_"..color_basename)

  local colored_group_name = "data_cable_bus_bracket_cross_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable_bus = 1,
    data_cable_bus_bracket_cross = 1,
    ["data_cable_bus_" .. color_basename] = 1,
    [colored_group_name] = 1
  }

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bus_bracket_cross",
    base_description = "Data Cable Bus Mounted Cross",

    description = "Data Cable Bus Mounted Cross (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.top.png^yatm_data_cable_bracket.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png^yatm_data_cable_bracket.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = cross_bracket_bus_nodebox,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "mounted_bus",
      accessible_dirs = {
        [Directions.D_WEST] = true,
        [Directions.D_EAST] = true,
        [Directions.D_NORTH] = true,
        [Directions.D_SOUTH] = true,
      }
    },

    after_place_node = data_cable_bracket_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = on_rotate,

    refresh_infotext = data_cable_refresh_infotext,
  })

  --
  -- Regular cables can only be placed on the ground
  --
  local colored_group_name = "data_cable_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable = 1,
    [colored_group_name] = 1
  }

  local node_name = "yatm_data_cables:data_cable_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_"..color_basename)

  local connects_to = {}
  if color_basename == "multi" then
    -- multi can connect to anything
    table.insert(connects_to, "group:data_cable_bus")
    table.insert(connects_to, "group:data_cable")
  else
    -- colored pipes can only connect to it's own color OR multi
    table.insert(connects_to, "group:" .. colored_group_name)
    table.insert(connects_to, "group:data_cable_multi")
    table.insert(connects_to, "group:data_cable_bus_" .. color_basename)
    table.insert(connects_to, "group:data_cable_bus_multi")
  end

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable",
    base_description = "Data Cable",

    description = "Data Cable (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".top.png",
      "yatm_data_cable_" .. color_basename .. ".top.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = data_cable_nodebox,

    connects_to = connects_to,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "cable",
    },

    after_place_node = data_cable_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = false,

    refresh_infotext = data_cable_refresh_infotext,
  })

  local colored_group_name = "data_cable_bus_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    --
    data_cable_bus = 1,
    [colored_group_name] = 1
  }

  local node_name = "yatm_data_cables:data_cable_bus_" .. color_basename
  table.insert(cables_to_migrate, "data_cable_bus_"..color_basename)

  local connects_to = {
    "group:yatm_data_device",
    "group:" .. colored_group_name,
  }

  if color_basename == "multi" then
    -- multi can connect to any cable
    table.insert(connects_to, "group:data_cable")
    table.insert(connects_to, "group:data_cable_bus")
  else
    -- colored cables can only connect to it's own color OR multi
    table.insert(connects_to, "group:data_cable_" .. color_basename)
    table.insert(connects_to, "group:data_cable_multi")
    table.insert(connects_to, "group:data_cable_bus_multi")
  end

  minetest.register_node(node_name, {
    basename = "yatm_data_cables:data_cable_bus",
    base_description = "Data Bus",

    description = "Data Bus (" .. color_name .. ")",

    codex_entry_id = "yatm_data_cables:data_cable_bus",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,

    sounds = yatm.node_sounds:build("metal"),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".bus.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
    },
    use_texture_alpha = "clip",

    drawtype = "nodebox",
    node_box = data_bus_nodebox,

    connects_to = connects_to,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "bus"
    },

    after_place_node = data_cable_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    on_rotate = false,

    refresh_infotext = data_cable_refresh_infotext,
  })
end

for _, cable_basename in ipairs(cables_to_migrate) do
  local dest = "yatm_data_cables:"..cable_basename

  minetest.register_lbm({
    name = "yatm_data_cables:migrate_" .. cable_basename,

    nodenames = {
      "yatm_data_network:"..cable_basename,
    },
    run_at_every_load = false,

    action = function (pos, node)
      node.name = dest
      minetest.swap_node(pos, node)
    end
  })
end
