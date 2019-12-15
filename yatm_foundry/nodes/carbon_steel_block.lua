minetest.register_node("yatm_foundry:carbon_steel_block", {
  basename = "yatm_foundry:carbon_steel_block",

  description = "Carbon Steel Block",

  groups = {cracky = 1, carbon_steel = 1},

  tiles = {
    "yatm_carbon_steel_block_side.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("yatm_foundry:carbon_steel_smooth_block", {
  basename = "yatm_foundry:carbon_steel_smooth_block",

  description = "Carbon Steel Smooth Block",

  groups = {cracky = 1, carbon_steel = 1},

  tiles = {
    "yatm_carbon_steel_block_smooth.side.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_metal_defaults(),
})

minetest.register_node("yatm_foundry:carbon_steel_base_panel_block", {
  basename = "yatm_foundry:carbon_steel_base_panel_block",

  description = "Carbon Steel Base Panel Block",

  groups = {cracky = 1, carbon_steel = 1},

  tiles = {
    "yatm_carbon_steel_block_base_panel.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_metal_defaults(),
})


minetest.register_node("yatm_foundry:carbon_steel_plain_panel_block", {
  basename = "yatm_foundry:carbon_steel_plain_panel_block",

  description = "Carbon Steel Plain Panel Block",

  groups = {cracky = 1, carbon_steel = 1},

  tiles = {
    "yatm_carbon_steel_block_plain_panel.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_metal_defaults(),
})
