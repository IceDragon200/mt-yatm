minetest.register_node("yatm_foundry:carbon_steel_block", {
  description = "Carbon Steel Block",
  groups = {cracky = 1},

  tiles = {
    "yatm_carbon_steel_block.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_metal_defaults(),
})