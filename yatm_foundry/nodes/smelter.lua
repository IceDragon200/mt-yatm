local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

minetest.register_node("yatm_foundry:smelter_off", {
  description = "Smelter",
  groups = groups,
  tiles = {
    "yatm_smelter_top.off.png",
    "yatm_smelter_bottom.off.png",
    "yatm_smelter_side.off.png",
    "yatm_smelter_side.off.png^[transformFX",
    "yatm_smelter_side.off.png",
    "yatm_smelter_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("yatm_foundry:smelter_on", {
  description = "Smelter",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  tiles = {
    "yatm_smelter_top.on.png",
    "yatm_smelter_bottom.on.png",
    "yatm_smelter_side.on.png",
    "yatm_smelter_side.on.png^[transformFX",
    "yatm_smelter_side.on.png",
    "yatm_smelter_side.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),
})
