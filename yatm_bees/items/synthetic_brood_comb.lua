minetest.register_craftitem("yatm_bees:synthetic_brood_comb_empty", {
  basename = "yatm_bees:synthetic_brood_comb",
  base_description = "Synthetic Brood Comb",

  description = "Empty Synthetic Brood Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
    empty_synthetic_brood_comb = 1,
  },

  inventory_image = "yatm_honey_combs_synthetic_brood_empty.png",
})

minetest.register_craftitem("yatm_bees:synthetic_brood_comb_full", {
  basename = "yatm_bees:synthetic_brood_comb",
  base_description = "Synthetic Brood Comb",

  description = "Full Synthetic Brood Comb",

  groups = {
    wax_comb = 1,
    synthetic_brood_comb = 1,
  },

  inventory_image = "yatm_honey_combs_synthetic_brood_full.png",
})
