minetest.register_craftitem("yatm_bees:synthetic_brood_comb_empty", {
  description = "Empty Synthetic Brood Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
    empty_synthetic_brood_comb = 1,
  },

  inventory_image = "yatm_synthetic_brood_comb_empty.png",
})

minetest.register_craftitem("yatm_bees:synthetic_brood_comb_full", {
  description = "Full Synthetic Brood Comb",

  groups = {
    wax_comb = 1,
    synthetic_brood_comb = 1,
  },

  inventory_image = "yatm_synthetic_brood_comb_full.png",
})
