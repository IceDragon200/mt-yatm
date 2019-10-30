--
--
--
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

local function data_cable_on_destruct(pos)
  print("data_cable_on_destruct", minetest.pos_to_string(pos))
end

local function data_cable_after_destruct(pos, old_node)
  print("data_cable_after_destruct", minetest.pos_to_string(pos))
  data_network:unregister_member(pos, old_node)
end

local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"multi", "Multi"}}, colors)

local data_cable_nodebox = {
  type = "connected",
  fixed          = yatm_core.Cuboid:new(5, 0, 5, 6, 2, 6):fast_node_box(),
  connect_top    = yatm_core.Cuboid:new(5, 2, 5, 6,14, 6):fast_node_box(), -- y+
  connect_bottom = yatm_core.Cuboid:new(0, 0, 0, 0, 0, 0):fast_node_box(), -- y-
  connect_front  = yatm_core.Cuboid:new(5, 0, 0, 6, 2, 5):fast_node_box(), -- z-
  connect_back   = yatm_core.Cuboid:new(5, 0,11, 6, 2, 5):fast_node_box(), -- z+
  connect_left   = yatm_core.Cuboid:new(0, 0, 5, 5, 2, 6):fast_node_box(), -- x-
  connect_right  = yatm_core.Cuboid:new(11,0, 5, 5, 2, 6):fast_node_box(), -- x+
}

local data_bus_nodebox = {
  type = "connected",
  fixed          = yatm_core.Cuboid:new(4, 0, 4, 8, 4, 8):fast_node_box(),
  connect_top    = yatm_core.Cuboid:new(5, 4, 5, 6,12, 6):fast_node_box(), -- y+
  connect_bottom = yatm_core.Cuboid:new(3, 0, 3,10, 1,10):fast_node_box(), -- y-
  connect_front  = yatm_core.Cuboid:new(5, 0, 0, 6, 2, 4):fast_node_box(), -- z-
  connect_back   = yatm_core.Cuboid:new(5, 0,12, 6, 2, 4):fast_node_box(), -- z+
  connect_left   = yatm_core.Cuboid:new(0, 0, 5, 4, 2, 6):fast_node_box(), -- x-
  connect_right  = yatm_core.Cuboid:new(12,0, 5, 4, 2, 6):fast_node_box(), -- x+
}

for _,color_pair in ipairs(colors) do
  local color_basename = color_pair[1]
  local color_name = color_pair[2]

  local colored_group_name = "data_cable_" .. color_basename
  local groups = { cracky = 1, data_cable = 1, [colored_group_name] = 1 }

  local node_name = "yatm_data_network:data_cable_" .. color_basename
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
    basename = "yatm_data_network:data_cable",

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

    refresh_infotext = data_cable_refresh_infotext,
  })

  local colored_group_name = "data_cable_bus_" .. color_basename
  local groups = { cracky = 1, data_cable_bus = 1, [colored_group_name] = 1 }

  local node_name = "yatm_data_network:data_cable_bus_" .. color_basename
  local connects_to = {
    "group:yatm_data_device",
  }
  if color_basename == "multi" then
    -- multi can connect to any cable
    table.insert(connects_to, "group:data_cable")
  else
    -- colored cables can only connect to it's own color OR multi
    table.insert(connects_to, "group:data_cable_" .. color_basename)
    table.insert(connects_to, "group:data_cable_multi")
  end

  minetest.register_node(node_name, {
    basename = "yatm_data_network:data_cable_bus",

    description = "Data Bus (" .. color_name .. ")",

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
    node_box = data_bus_nodebox,

    connects_to = connects_to,

    dye_color = color_basename,

    data_network_device = {
      color = color_basename,
      type = "bus",
    },

    after_place_node = data_cable_after_place_node,
    after_destruct = data_cable_after_destruct,
    on_destruct = data_cable_on_destruct,

    refresh_infotext = data_cable_refresh_infotext,
  })
end
