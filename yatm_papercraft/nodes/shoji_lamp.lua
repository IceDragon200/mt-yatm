--[[

  A paper lamp.

]]
local shoji_lamp_node_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 2, 3, 2,12,12,12):fast_node_box(), -- main box
    -- legs
    yatm_core.Cuboid:new( 2, 0, 2, 2, 3, 2):fast_node_box(),
    yatm_core.Cuboid:new( 2, 0,12, 2, 3, 2):fast_node_box(),
    yatm_core.Cuboid:new(12, 0,12, 2, 3, 2):fast_node_box(),
    yatm_core.Cuboid:new(12, 0, 2, 2, 3, 2):fast_node_box(),
  },
}

local lamp_sounds = default.node_sound_leaves_defaults()

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
  light_source = default.LIGHT_MAX,

  drawtype = "nodebox",
  node_box = shoji_lamp_node_box,
})
