local glass_sounds = default.node_sound_glass_defaults()

local h = 5
local pie_dish_node_box = {
  type = "fixed",
  fixed = {
    -- Base
    yatm_core.Cuboid:new( 2, 0,  2,  12, 1, 12):fast_node_box(),

    -- Sides
    yatm_core.Cuboid:new( 1, 0,  1,  14, h,  1):fast_node_box(),
    yatm_core.Cuboid:new(14, 0,  1,   1, h, 14):fast_node_box(),
    yatm_core.Cuboid:new( 1, 0, 14,  14, h,  1):fast_node_box(),
    yatm_core.Cuboid:new( 1, 0,  1,   1, h, 14):fast_node_box(),

    -- Rim
    yatm_core.Cuboid:new( 0, h - 1,  0,  16, 1,  1):fast_node_box(),
    yatm_core.Cuboid:new(15, h - 1,  0,   1, 1, 16):fast_node_box(),
    yatm_core.Cuboid:new( 0, h - 1, 15,  16, 1,  1):fast_node_box(),
    yatm_core.Cuboid:new( 0, h - 1,  0,   1, 1, 16):fast_node_box(),
  },
}

minetest.register_node("yatm_culinary:pie_dish", {
  description = "Pie Dish",

  groups = {
    cracky = 3
  },

  tiles = {
    "yatm_pie_dish_top.png",
    "yatm_pie_dish_bottom.png",
    "yatm_pie_dish_side.png",
    "yatm_pie_dish_side.png",
    "yatm_pie_dish_side.png",
    "yatm_pie_dish_side.png",
  },

  sounds = glass_sounds,

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = pie_dish_node_box,
})
