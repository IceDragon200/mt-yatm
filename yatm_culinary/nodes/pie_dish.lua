local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local glass_sounds = yatm.node_sounds:build("glass")

local h = 5
local pie_dish_node_box = {
  type = "fixed",
  fixed = {
    -- Base
    ng( 2, 0,  2,  12, 1, 12),

    -- Sides
    ng( 1, 0,  1,  14, h,  1),
    ng(14, 0,  1,   1, h, 14),
    ng( 1, 0, 14,  14, h,  1),
    ng( 1, 0,  1,   1, h, 14),

    -- Rim
    ng( 0, h - 1,  0,  16, 1,  1),
    ng(15, h - 1,  0,   1, 1, 16),
    ng( 0, h - 1, 15,  16, 1,  1),
    ng( 0, h - 1,  0,   1, 1, 16),
  },
}

minetest.register_node("yatm_culinary:pie_dish", {
  codex_entry_id = "yatm_culinary:pie_dish",

  basename = "yatm_culinary:pie_dish",

  description = "Pie Dish",

  groups = {
    cracky = nokore.dig_class("copper"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
  },

  use_texture_alpha = "opaque",
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
