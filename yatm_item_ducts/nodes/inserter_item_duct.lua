local item_transport_network = assert(yatm.item_transport.item_transport_network)

local function on_construct(pos)
  local node = minetest.get_node(pos)
  item_transport_network:register_member(pos, node)
end

local function duct_after_destruct(pos, _old_node)
  item_transport_network:unregister_member(pos)
end

local fsize = (10 / 16.0) / 2
local size = (8 / 16.0) / 2

minetest.register_node("yatm_item_ducts:inserter_item_duct", {
  description = "Inserter Item Duct",

  codex_entry_id = "yatm_item_ducts:inserter_item_duct",

  groups = {
    cracky = nokore.dig_class("copper"),
    item_network_device = 1,
    inserter_item_duct = 1,
    inserter_item_device = 1,
  },

  sounds = yatm.node_sounds:build("metal"),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    {
      name = "yatm_item_duct_inserter.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5
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
    "group:item_interface_in",
    "group:extractor_item_device",
    "group:transporter_item_duct",
  },

  item_transport_device = {
    type = "inserter",
    subtype = "duct",
  },

  on_construct = on_construct,
  after_destruct = duct_after_destruct,
})
