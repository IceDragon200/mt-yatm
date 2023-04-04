local mod = assert(yatm_item_hoppers)

local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)

local item_transport_network = assert(yatm.item_transport.item_transport_network)

local function after_place_node(pos, _placer, _itemstack, _pointed_thing)
  local node = minetest.get_node(pos)
  item_transport_network:register_member(pos, node)
end

local function after_destruct(pos, _old_node)
  item_transport_network:unregister_member(pos)
end

mod:register_node("wood_hopper_down", {
  description = mod.S("Wood Hopper [Down]"),

  groups = {
    cracky = nokore.dig_class("wme"),
    item_network_device = 1,
    item_hopper = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",

    fixed = {
      ng(0, 8, 0, 16, 8, 1),
      ng(0, 8, 15, 16, 8, 1),
      ng(0, 8, 1, 1, 8, 14),
      ng(15, 8, 1, 1, 8, 14),
      ng(1, 8, 1, 14, 1, 14),
      --
      ng(4, 4, 4, 8, 4, 8),
      ng(6, 0, 6, 4, 4, 4),
    },
  },

  tiles = {
    "yatm_hopper_wood.top.png",
    "yatm_hopper_wood.bottom.png",
    "yatm_hopper_wood.side.spout.down.png",
    "yatm_hopper_wood.side.spout.down.png",
    "yatm_hopper_wood.side.spout.down.png",
    "yatm_hopper_wood.side.spout.down.png",
  },
  use_texture_alpha = "opaque",

  item_transport_device = {
    type = "hopper",
    subtype = "down",
  },

  after_place_node = after_place_node,
  after_destruct = after_destruct,
})

mod:register_node("wood_hopper_side", {
  description = mod.S("Wood Hopper [Side]"),

  groups = {
    cracky = nokore.dig_class("wme"),
    item_network_device = 1,
    item_hopper = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",

    fixed = {
      ng(0, 8, 0, 16, 8, 1),
      ng(0, 8, 15, 16, 8, 1),
      ng(0, 8, 1, 1, 8, 14),
      ng(15, 8, 1, 1, 8, 14),
      ng(1, 8, 1, 14, 1, 14),
      --
      ng(4, 4, 4, 8, 4, 8),
      ng(12, 4, 6, 4, 4, 4),
    },
  },

  tiles = {
    "yatm_hopper_wood.top.png",
    "yatm_hopper_wood.bottom.spout.side.png",
    "yatm_hopper_wood.side.spout.side.png",
    "yatm_hopper_wood.side.spout.side.png",
    "yatm_hopper_wood.side.spout.side.png^[transformFX",
    "yatm_hopper_wood.side.spout.side.png",
  },
  use_texture_alpha = "opaque",

  item_transport_device = {
    type = "hopper",
    subtype = "side",
  },

  after_place_node = after_place_node,
  after_destruct = after_destruct,
})
