minetest.register_craftitem("yatm_bees:synthetic_comb_empty", {
  description = "Empty Synthetic Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
  },

  inventory_image = "yatm_synthetic_comb_empty.png",
})

minetest.register_craftitem("yatm_bees:synthetic_comb_full", {
  description = "Full Synthetic Comb",

  groups = {
    wax_comb = 1,
    synthetic_comb = 1,
  },

  inventory_image = "yatm_synthetic_comb_full.png",
})
