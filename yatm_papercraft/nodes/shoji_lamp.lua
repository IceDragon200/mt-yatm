--[[

  A paper lamp.

]]
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local shoji_lamp_node_box = {
  type = "fixed",
  fixed = {
    ng( 2, 3, 2,12,12,12), -- main box
    -- legs
    ng( 2, 0, 2, 2, 3, 2),
    ng( 2, 0,12, 2, 3, 2),
    ng(12, 0,12, 2, 3, 2),
    ng(12, 0, 2, 2, 3, 2),
  },
}

local lamp_sounds = yatm.node_sounds:build("leaves")

minetest.register_node("yatm_papercraft:shoji_lamp_off", {
  basename = "yatm_papercraft:shoji_lamp",

  description = "Shoji Lamp [OFF]",

  groups = {
    choppy = 1,
    paper = 1,
    lamp = 1,
  },

  is_ground_content = false,
  sounds = lamp_sounds,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_shoji_lamp_top.off.png",
    "yatm_shoji_lamp_bottom.off.png",
    "yatm_shoji_lamp_side.off.png",
    "yatm_shoji_lamp_side.off.png",
    "yatm_shoji_lamp_side.off.png",
    "yatm_shoji_lamp_side.off.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = shoji_lamp_node_box,

  on_rightclick = function (pos, node, user)
    local new_node = {
      name = "yatm_papercraft:shoji_lamp_on",
    }
    minetest.swap_node(pos, new_node)
  end,
})

minetest.register_node("yatm_papercraft:shoji_lamp_on", {
  basename = "yatm_papercraft:shoji_lamp",

  description = "Shoji Lamp [ON]",

  groups = {
    choppy = 1,
    paper = 1,
    lamp = 1,
    --not_in_creative_inventory = 1,
  },

  is_ground_content = false,
  sounds = lamp_sounds,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_shoji_lamp_top.on.png",
    "yatm_shoji_lamp_bottom.on.png",
    "yatm_shoji_lamp_side.on.png",
    "yatm_shoji_lamp_side.on.png",
    "yatm_shoji_lamp_side.on.png",
    "yatm_shoji_lamp_side.on.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = false,
  light_source = minetest.LIGHT_MAX,

  drawtype = "nodebox",
  node_box = shoji_lamp_node_box,

  on_rightclick = function (pos, node, user)
    local new_node = {
      name = "yatm_papercraft:shoji_lamp_off",
    }
    minetest.swap_node(pos, new_node)
  end,
})
