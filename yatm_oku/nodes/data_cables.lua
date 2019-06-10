local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"multi", "Multi"}}, colors)

for _,color_pair in ipairs(colors) do
  local color_basename = color_pair[1]
  local color_name = color_pair[2]

  local colored_group_name = "data_cable_" .. color_basename
  local groups = { cracky = 1, data_cable = 1, [colored_group_name] = 1 }

  local node_name = "yatm_oku:data_cable_" .. color_basename
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
    description = "Data Cable (" .. color_name .. ")",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,

    sounds = default.node_sound_metal_defaults(),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".top.png",
      "yatm_data_cable_" .. color_basename .. ".top.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
      "yatm_data_cable_" .. color_basename .. ".side.png",
    },

    drawtype = "nodebox",
    node_box = {
      type = "connected",
      fixed          = yatm_core.Cuboid:new(5, 0, 5, 6, 2, 6):fast_node_box(),
      connect_top    = yatm_core.Cuboid:new(5, 2, 5, 6,14, 6):fast_node_box(), -- y+
      connect_bottom = yatm_core.Cuboid:new(0, 0, 0, 0, 0, 0):fast_node_box(), -- y-
      connect_front  = yatm_core.Cuboid:new(5, 0, 0, 6, 2, 5):fast_node_box(), -- z-
      connect_back   = yatm_core.Cuboid:new(5, 0,11, 6, 2, 5):fast_node_box(), -- z+
      connect_left   = yatm_core.Cuboid:new(0, 0, 5, 5, 2, 6):fast_node_box(), -- x-
      connect_right  = yatm_core.Cuboid:new(11,0, 5, 5, 2, 6):fast_node_box(), -- x+
    },

    connects_to = connects_to,

    dye_color = color_basename,

    --after_place_node = pipe_after_place_node,
    --after_destruct = pipe_after_destruct,
    --on_destruct = pipe_on_destruct,
  })

  local colored_group_name = "data_cable_bus_" .. color_basename
  local groups = { cracky = 1, data_cable_bus = 1, [colored_group_name] = 1 }

  local node_name = "yatm_oku:data_cable_bus_" .. color_basename
  local connects_to = {
    "group:yatm_data_device",
  }
  if color_basename == "multi" then
    -- multi can connect to anything
    table.insert(connects_to, "group:data_cable_bus")
    table.insert(connects_to, "group:data_cable")
  else
    -- colored pipes can only connect to it's own color OR multi
    table.insert(connects_to, "group:" .. colored_group_name)
    table.insert(connects_to, "group:data_cable_bus_multi")
    table.insert(connects_to, "group:data_cable_" .. color_basename)
    table.insert(connects_to, "group:data_cable_multi")
  end

  minetest.register_node(node_name, {
    description = "Data Cable Bus (" .. color_name .. ")",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,

    sounds = default.node_sound_metal_defaults(),

    tiles = {
      "yatm_data_cable_" .. color_basename .. ".bus.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.top.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
      "yatm_data_cable_" .. color_basename .. ".bus.side.png",
    },

    drawtype = "nodebox",
    node_box = {
      type = "connected",
      fixed          = yatm_core.Cuboid:new(4, 0, 4, 8, 4, 8):fast_node_box(),
      connect_top    = yatm_core.Cuboid:new(5, 4, 5, 6,12, 6):fast_node_box(), -- y+
      connect_bottom = yatm_core.Cuboid:new(0, 0, 0, 0, 0, 0):fast_node_box(), -- y-
      connect_front  = yatm_core.Cuboid:new(5, 0, 0, 6, 2, 4):fast_node_box(), -- z-
      connect_back   = yatm_core.Cuboid:new(5, 0,12, 6, 2, 4):fast_node_box(), -- z+
      connect_left   = yatm_core.Cuboid:new(0, 0, 5, 4, 2, 6):fast_node_box(), -- x-
      connect_right  = yatm_core.Cuboid:new(12,0, 5, 4, 2, 6):fast_node_box(), -- x+
    },

    connects_to = connects_to,

    dye_color = color_basename,

    --after_place_node = pipe_after_place_node,
    --after_destruct = pipe_after_destruct,
    --on_destruct = pipe_on_destruct,
  })
end
