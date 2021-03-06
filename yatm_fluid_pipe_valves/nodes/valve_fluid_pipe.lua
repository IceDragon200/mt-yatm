local list_concat = assert(foundation.com.list_concat)
local table_merge = assert(foundation.com.table_merge)
local fluid_transport_cluster = assert(yatm.fluids.fluid_transport_cluster)

local function pipe_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  fluid_transport_cluster:register_member(pos, node)
end

local function pipe_on_destruct(pos)
  print("valve_fluid_pipe_on_destruct", minetest.pos_to_string(pos))
end

local function pipe_after_destruct(pos, _old_node)
  print("valve_fluid_pipe_after_destruct", minetest.pos_to_string(pos))
  fluid_transport_cluster:unregister_member(pos)
end

local fsize = (8 / 16.0) / 2
local size = (6 / 16.0) / 2

local valve_nodebox = {
  type = "connected",
  fixed          = {-fsize, -fsize, -fsize, fsize,  fsize, fsize},
  connect_top    = {-size, -size, -size, size,  0.5,  size}, -- y+
  connect_bottom = {-size, -0.5,  -size, size,  size, size}, -- y-
  connect_front  = {-size, -size, -0.5,  size,  size, size}, -- z-
  connect_back   = {-size, -size,  size, size,  size, 0.5 }, -- z+
  connect_left   = {-0.5,  -size, -size, size,  size, size}, -- x-
  connect_right  = {-size, -size, -size, 0.5,   size, size}, -- x+
}

local valve_mesecon_rules = {
  {x =  0, y =  0, z = -1},
  {x =  1, y =  0, z =  0},
  {x = -1, y =  0, z =  0},
  {x =  0, y =  0, z =  1},
  {x =  1, y =  1, z =  0},
  {x =  1, y = -1, z =  0},
  {x = -1, y =  1, z =  0},
  {x = -1, y = -1, z =  0},
  {x =  0, y =  1, z =  1},
  {x =  0, y = -1, z =  1},
  {x =  0, y =  1, z = -1},
  {x =  0, y = -1, z = -1},
}

local basename = "yatm_fluid_pipe_valves:valve_fluid_pipe"
for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  local colored_group_name = "valve_fluid_pipe_" .. color_basename
  local groups = {
    cracky = 1,
    fluid_network_device = 1,
    valve_fluid_pipe = 1,
    [colored_group_name] = 1,
  }

  local node_name = basename .. "_" .. color_basename
  local connects_to = {
    "group:extractor_fluid_device",
    "group:inserter_fluid_device",
  }
  if color_basename == "default" then
    -- default can connect to anything
    table.insert(connects_to, "group:transporter_fluid_pipe")
    table.insert(connects_to, "group:valve_fluid_pipe")
  else
    -- colored pipes can only connect to it's own color OR default
    table.insert(connects_to, "group:" .. colored_group_name)
    table.insert(connects_to, "group:valve_fluid_pipe_default")
    table.insert(connects_to, "group:transporter_fluid_pipe_" .. color_basename)
    table.insert(connects_to, "group:transporter_fluid_pipe_default")
  end

  minetest.register_node(node_name .. "_off", {
    basename = basename,
    base_description = "Valve Fluid Pipe",

    description = "Valve Fluid Pipe (" .. color_name .. ")",

    drop = node_name .. "_off",

    groups = groups,

    sounds = yatm.node_sounds:build("metal"),

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {"yatm_fluid_pipe_valve_" .. color_basename .. "_valve.off.png"},

    fluid_transport_device = {
      type = "valve",
      state = "off",
      color = color_basename,
    },

    drawtype = "nodebox",
    node_box = valve_nodebox,

    connects_to = connects_to,

    dye_color = color_basename,

    after_place_node = pipe_after_place_node,
    after_destruct = pipe_after_destruct,
    on_destruct = pipe_on_destruct,

    mesecons = {
      effector = {
        rules = valve_mesecon_rules,

        action_on = function (pos, node)
          node.name = node_name .. "_on"
          minetest.swap_node(pos, node)
          fluid_transport_cluster:update_member(pos, node)
        end,
      }
    },
  })

  minetest.register_node(node_name .. "_on", {
    basename = basename,
    base_description = "Valve Fluid Pipe",

    description = "Valve Fluid Pipe (" .. color_name .. ")",

    drop = node_name .. "_off",

    groups = table_merge(groups, {not_in_creative_inventory = 1}),

    sounds = yatm.node_sounds:build("metal"),

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {"yatm_fluid_pipe_valve_" .. color_basename .. "_valve.on.png"},

    fluid_transport_device = {
      type = "valve",
      state = "on",
      color = color_basename,
    },

    drawtype = "nodebox",
    node_box = valve_nodebox,

    connects_to = connects_to,

    dye_color = color_basename,

    after_place_node = pipe_after_place_node,
    after_destruct = pipe_after_destruct,
    on_destruct = pipe_on_destruct,

    mesecons = {
      effector = {
        rules = valve_mesecon_rules,

        action_off = function (pos, node)
          node.name = node_name .. "_off"
          minetest.swap_node(pos, node)
          fluid_transport_cluster:update_member(pos, node)
        end,
      }
    },
  })
end
