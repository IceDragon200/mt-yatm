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

minetest.register_node("yatm_fluid_pipes:inserter_fluid_pipe", {
  basename = "yatm_fluid_pipes:inserter_fluid_pipe",

  description = "Inserter Fluid Pipe",

  codex_entry_id = "yatm_fluid_pipes:inserter_fluid_pipe",

  groups = {
    cracky = nokore.dig_class("copper"),
    fluid_network_device = 1,
    inserter_fluid_pipe = 1,
    inserter_fluid_device = 1,
  },

  sounds = yatm.node_sounds:build("metal"),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    {
      name = "yatm_fluid_pipe_inserter.on.png",
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
    "group:fluid_interface_in",
    "group:extractor_fluid_device",
    "group:valve_fluid_pipe",
    "group:transporter_fluid_pipe",
  },

  fluid_transport_device = {
    type = "inserter",
    subtype = "duct",
    bandwidth = 1000,
  },

  on_construct = on_construct,
  on_destruct = on_destruct,
  after_destruct = after_destruct,
})
