local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local variants = {
  ["plain"] = "Plain",
  ["design_1"] = "Design #1",
  ["design_2"] = "Design #2",
  ["design_3"] = "Design #3",
  ["design_4"] = "Design #4",
}

local wood_sounds = yatm.node_sounds:build("wood")

for variant_basename, variant_name in pairs(variants) do
  minetest.register_node("yatm_papercraft:shoji_panel_block" .. variant_basename, {
    basename = "yatm_papercraft:shoji_panel_block",
    base_description = "Shoji Panel Block",

    description = "Shoji Panel Block " .. variant_name,

    groups = {
      cracky = 1,
    },

    tiles = {
      "yatm_shoji_panel_" .. variant_basename .. ".png",
    },

    paramtype = "none",
    paramtype2 = "facedir",

    sounds = wood_sounds,
  })

  minetest.register_node("yatm_papercraft:shoji_panel_" .. variant_basename, {
    basename = "yatm_papercraft:shoji_panel",
    base_description = "Shoji Panel",

    description = "Shoji Panel " .. variant_name,

    groups = {
      cracky = 1,
    },

    tiles = {
      "yatm_shoji_panel_" .. variant_basename .. ".png",
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 1, 16),
      },
    },

    sounds = wood_sounds,
  })
end
