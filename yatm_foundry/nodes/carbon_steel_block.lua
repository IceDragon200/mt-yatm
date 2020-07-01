minetest.register_node("yatm_foundry:carbon_steel_block", {
  basename = "yatm_foundry:carbon_steel_block",

  description = "Carbon Steel Block",

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = {cracky = 1, carbon_steel_block = 1},

  tiles = {
    "yatm_carbon_steel_block_side.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),
})

minetest.register_node("yatm_foundry:carbon_steel_smooth_block", {
  basename = "yatm_foundry:carbon_steel_smooth_block",

  description = "Carbon Steel Smooth Block",

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = {cracky = 1, carbon_steel_block = 1},

  tiles = {
    "yatm_carbon_steel_block_smooth.side.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),
})

minetest.register_node("yatm_foundry:carbon_steel_base_panel_block", {
  basename = "yatm_foundry:carbon_steel_base_panel_block",

  description = "Carbon Steel Base Panel Block",

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = {cracky = 1, carbon_steel_block = 1},

  tiles = {
    "yatm_carbon_steel_block_base_panel.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),
})


minetest.register_node("yatm_foundry:carbon_steel_plain_panel_block", {
  basename = "yatm_foundry:carbon_steel_plain_panel_block",

  description = "Carbon Steel Plain Panel Block",

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = {cracky = 1, carbon_steel_block = 1},

  tiles = {
    "yatm_carbon_steel_block_plain_panel.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),
})

if stairs then
  stairs.register_stair_and_slab(
    "yatm_foundry_carbon_steel_block",
    "yatm_foundry:carbon_steel_block",
    {cracky = 1, concrete = 1},
    {"yatm_carbon_steel_block_side.png"},
    "Carbon Steel Stair",
    "Carbon Steel Slab",
    yatm.node_sounds:build("metal"),
    false
  )

  stairs.register_stair_and_slab(
    "yatm_foundry_carbon_steel_smooth_block",
    "yatm_foundry:carbon_steel_smooth_block",
    {cracky = 1, concrete = 1},
    {"yatm_carbon_steel_block_smooth.side.png"},
    "Carbon Steel Smooth Stair",
    "Carbon Steel Smooth Slab",
    yatm.node_sounds:build("metal"),
    false
  )

  stairs.register_stair_and_slab(
    "yatm_foundry_carbon_steel_base_panel_block",
    "yatm_foundry:carbon_steel_base_panel_block",
    {cracky = 1, concrete = 1},
    {"yatm_carbon_steel_block_base_panel.png"},
    "Carbon Steel Base Panel Stair",
    "Carbon Steel Base Panel Slab",
    yatm.node_sounds:build("metal"),
    false
  )

  stairs.register_stair_and_slab(
    "yatm_foundry_carbon_steel_plain_panel_block",
    "yatm_foundry:carbon_steel_plain_panel_block",
    {cracky = 1, concrete = 1},
    {"yatm_carbon_steel_block_plain_panel.png"},
    "Carbon Steel Plain Panel Stair",
    "Carbon Steel Plain Panel Slab",
    yatm.node_sounds:build("metal"),
    false
  )
end
