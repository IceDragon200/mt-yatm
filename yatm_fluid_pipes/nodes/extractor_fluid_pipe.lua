local FluidTransportNetwork = assert(yatm.fluids.FluidTransportNetwork)

local function pipe_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  FluidTransportNetwork:register_member(pos, node)
end

local function pipe_on_destruct(pos)
  print("transporter_fluid_pipe_on_destruct", minetest.pos_to_string(pos))
end

local function pipe_after_destruct(pos, _old_node)
  FluidTransportNetwork:unregister_member(pos)
end

local fsize = (10 / 16.0) / 2
local size = (8 / 16.0) / 2

minetest.register_node("yatm_fluid_pipes:extractor_fluid_pipe", {
  description = "Extractor Fluid Pipe",

  groups = { cracky = 1, extractor_fluid_pipe = 1, extractor_fluid_device = 1 },

  sounds = default.node_sound_metal_defaults(),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    {
      name = "yatm_fluid_pipe_extractor.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5,
      },
    },
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

  connects_to = {
    "group:fluid_interface_out",
    "group:transporter_fluid_pipe",
    "group:valve_fluid_pipe",
    "group:inserter_fluid_device",
  },

  fluid_transport_device = {
    type = "extractor",
    subtype = "duct",
    bandwidth = 1000,
  },

  on_destruct = pipe_on_destruct,

  after_place_node = pipe_after_place_node,
  after_destruct = pipe_after_destruct,
})
