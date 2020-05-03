minetest.register_node("yatm_bees:bee_hive", {
  description = "Bee Hive",

  groups = {
    bee_hive = 1,
  },

  tiles = {
    "yatm_bee_hive_top.png",
    "yatm_bee_hive_bottom.png",
    "yatm_bee_hive_side.png",
    "yatm_bee_hive_side.png^[transformFX",
    "yatm_bee_hive_side.png",
    "yatm_bee_hive_front.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
})
