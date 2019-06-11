local FluidTransportNetwork = assert(yatm.fluids.FluidTransportNetwork)

local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"default", "Default"}}, colors)

local function pipe_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  FluidTransportNetwork:register_member(pos, node)
end

local function pipe_on_destruct(pos)
  print("transporter_fluid_pipe_on_destruct", minetest.pos_to_string(pos))
end

local function pipe_after_destruct(pos, _old_node)
  print("transporter_fluid_pipe_after_destruct", minetest.pos_to_string(pos))
  FluidTransportNetwork:unregister_member(pos)
end

local fsize = (6 / 16.0) / 2
local size = (6 / 16.0) / 2

for _,color_pair in ipairs(colors) do
  local color_basename = color_pair[1]
  local color_name = color_pair[2]

  local colored_group_name = "transporter_fluid_pipe_" .. color_basename
  local groups = { cracky = 1, fluid_network_device = 1, transporter_fluid_pipe = 1, [colored_group_name] = 1 }

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
    description = "Transporter Fluid Pipe (" .. color_name .. ")",

    groups = groups,

    paramtype = "light",
    paramtype2 = "facedir",

    sounds = default.node_sound_metal_defaults(),

    tiles = {"yatm_fluid_pipe_" .. color_basename .. "_pipe.on.png"},

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

    after_place_node = pipe_after_place_node,
    after_destruct = pipe_after_destruct,
    on_destruct = pipe_on_destruct,
  })
end
