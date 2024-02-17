local mod = assert(yatm_fluid_pipes)
local fluid_transport_network = assert(yatm.fluids.fluid_transport_network)

local function on_construct(pos)
  local node = minetest.get_node(pos)
  fluid_transport_network:register_member(pos, node)
end

local function on_destruct(pos)
  --
end

local function after_destruct(pos, _old_node)
  fluid_transport_network:unregister_member(pos)
end

local fsize = (10 / 16.0) / 2
local size = (8 / 16.0) / 2

mod:register_node("extractor_fluid_pipe", {
  basename = mod:make_name("extractor_fluid_pipe"),

  description = mod.S("Extractor Fluid Pipe"),

  codex_entry_id = mod:make_name("extractor_fluid_pipe"),

  groups = {
    cracky = nokore.dig_class("copper"),
    fluid_network_device = 1,
    extractor_fluid_pipe = 1,
    extractor_fluid_device = 1,
  },

  sounds = yatm.node_sounds:build("metal"),

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
  use_texture_alpha = "opaque",

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
    bandwidth = 6000,
  },

  on_construct = on_construct,

  on_destruct = on_destruct,
  after_destruct = after_destruct,
})
