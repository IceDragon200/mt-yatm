local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

minetest.register_node("yatm_foundry:kiln_off", {
  description = "Kiln",
  groups = groups,
  tiles = {
    "yatm_kiln_top.off.png",
    "yatm_kiln_bottom.off.png",
    "yatm_kiln_side.off.png",
    "yatm_kiln_side.off.png^[transformFX",
    "yatm_kiln_back.off.png",
    "yatm_kiln_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("yatm_foundry:kiln_on", {
  description = "Kiln",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
  tiles = {
    "yatm_kiln_top.on.png",
    "yatm_kiln_bottom.on.png",
    "yatm_kiln_side.on.png",
    "yatm_kiln_side.on.png^[transformFX",
    "yatm_kiln_back.on.png",
    "yatm_kiln_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  sounds = default.node_sound_stone_defaults(),
})
