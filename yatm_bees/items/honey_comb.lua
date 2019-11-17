minetest.register_craftitem("yatm_bees:honey_comb_empty", {
  basename = "yatm_bees:honey_comb",
  base_description = "Honey Comb",

  description = "Empty Honey Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
    empty_honey_comb = 1,
  },

  inventory_image = "yatm_honey_combs_normal_empty.png",
})

minetest.register_craftitem("yatm_bees:honey_comb_full", {
  basename = "yatm_bees:honey_comb",
  base_description = "Honey Comb",

  description = "Full Honey Comb",

  groups = {
    wax_comb = 1,
    honey_comb = 1
  },

  inventory_image = "yatm_honey_combs_normal_full.png",
})
