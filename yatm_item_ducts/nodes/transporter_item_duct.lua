local list_concat = assert(foundation.com.list_concat)

local item_transport_network = assert(yatm.item_transport.item_transport_network)

local function duct_after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  item_transport_network:register_member(pos, node)
end

local function duct_after_destruct(pos, _old_node)
  item_transport_network:unregister_member(pos)
end

local fsize = (6 / 16.0) / 2
local size = (6 / 16.0) / 2

for _,row in ipairs(yatm.colors_with_default) do
  local color_basename = row.name
  local color_name = row.description

  local colored_group_name = "transporter_item_duct_" .. color_basename
  local groups = { cracky = 1, item_network_device = 1, transporter_item_duct = 1, [colored_group_name] = 1 }

  local node_name = "yatm_item_ducts:transporter_item_duct_" .. color_basename
  local connects_to = {
    "group:extractor_item_device",
    "group:inserter_item_device",
  }
  if color_basename == "default" then
    -- default can connect to anything
    table.insert(connects_to, "group:transporter_item_duct")
  else
    -- colored ducts can only connect to it's own color OR default
    table.insert(connects_to, "group:" .. colored_group_name)
    table.insert(connects_to, "group:transporter_item_duct_default")
  end

  minetest.register_node(node_name, {
    basename = "yatm_item_ducts:transporter_item_duct",

    base_description = "Transporter Item Duct",
    description = "Transporter Item Duct (" .. color_name .. ")",

    codex_entry_id = "yatm_item_ducts:transporter_item_duct",

    groups = groups,

    sounds = yatm.node_sounds:build("metal"),

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {
      "yatm_item_duct_" .. color_basename .. "_pipe.on.png"
    },

    item_transport_device = {
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

    after_place_node = duct_after_place_node,
    after_destruct = duct_after_destruct,
  })
end
