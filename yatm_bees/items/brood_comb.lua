minetest.register_craftitem("yatm_bees:brood_comb_empty", {
  basename = "yatm_bees:brood_comb",
  base_description = "Brood Comb",

  description = "Empty Brood Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
    empty_brood_comb = 1,
  },

  inventory_image = "yatm_honey_combs_normal_brood_empty.png",
})

minetest.register_craftitem("yatm_bees:brood_comb_full", {
  basename = "yatm_bees:brood_comb",
  base_description = "Brood Comb",

  description = "Full Brood Comb",

  groups = {
    wax_comb = 1,
    brood_comb = 1
  },

  inventory_image = "yatm_honey_combs_normal_brood_full.png",
})
