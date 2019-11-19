local variants = {
  ["plain"] = "Plain",
  ["design_1"] = "Design #1",
  ["design_2"] = "Design #2",
  ["design_3"] = "Design #3",
  ["design_4"] = "Design #4",
}

for variant_basename, variant_name in pairs(variants) do
  minetest.register_node("yatm_papercraft:shoji_panel_block" .. variant_basename, {
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

    sounds = default.node_sound_wood_defaults(),
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
        yatm_core.Cuboid:new(0, 0, 0, 16, 1, 16):fast_node_box(),
      },
    },

    sounds = default.node_sound_wood_defaults(),
  })
end
