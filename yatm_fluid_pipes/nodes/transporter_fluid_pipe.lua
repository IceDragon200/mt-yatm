local list_concat = assert(foundation.com.list_concat)
local fluid_transport_network = assert(yatm.fluids.fluid_transport_network)

local function on_construct(pos)
  local node = minetest.get_node(pos)
  fluid_transport_network:register_member(pos, node)
end

local function pipe_on_destruct(pos)
end

local function pipe_after_destruct(pos, _old_node)
  fluid_transport_network:unregister_member(pos)
end

local fsize = (6 / 16.0) / 2
local size = (6 / 16.0) / 2

for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  local colored_group_name = "transporter_fluid_pipe_" .. color_basename
  local groups = {
    cracky = nokore.dig_class("copper"),
    fluid_network_device = 1,
    transporter_fluid_pipe = 1,
    [colored_group_name] = 1,
  }

  local node_name = "yatm_fluid_pipes:transporter_fluid_pipe_" .. color_basename
  local connects_to = {
    "group:extractor_fluid_device",
    "group:inserter_fluid_device",
  }
  if color_basename == "default" then
    -- default can connect to anything
    table.insert(connects_to, "group:valve_fluid_pipe")
    table.insert(connects_to, "group:transporter_fluid_pipe")
  else
    -- colored pipes can only connect to it's own color OR default
    table.insert(connects_to, "group:" .. colored_group_name)
    table.insert(connects_to, "group:transporter_fluid_pipe_default")
    table.insert(connects_to, "group:valve_fluid_pipe_" .. color_basename)
    table.insert(connects_to, "group:valve_fluid_pipe_default")
  end

  minetest.register_node(node_name, {
    basename = "yatm_fluid_pipes:transporter_fluid_pipe",

    description = "Transporter Fluid Pipe (" .. color_name .. ")",

    codex_entry_id = "yatm_fluid_pipes:transporter_fluid_pipe",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = yatm.node_sounds:build("metal"),

    tiles = {"yatm_fluid_pipe_" .. color_basename .. "_pipe.on.png"},
    use_texture_alpha = "opaque",

    fluid_transport_device = {
      type = "transporter",
      color = color_basename,
    },

    drawtype = "nodebox",
    node_box = {
      type = "connected",
      fixed          = {-fsize, -fsize, -fsize, fsize,  fsize, fsize},
      connect_top    = {-size, -size, -size, size,  0.5,  size}, -- y+
      connect_bottom = {-size, -0.5,  -size, size,  size, size}, -- y-
      connect_front  = {-size, -size, -0.5,  size,  size, size}, -- z-
      connect_back   = {-size, -size,  size, size,  size, 0.5 }, -- z+
      connect_left   = {-0.5,  -size, -size, size,  size, size}, -- x-
      connect_right  = {-size, -size, -size, 0.5,   size, size}, -- x+
    },

    connects_to = connects_to,

    dye_color = color_basename,

    on_construct = on_construct,
    on_destruct = pipe_on_destruct,
  })
end
