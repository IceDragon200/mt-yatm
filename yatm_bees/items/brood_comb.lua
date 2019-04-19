minetest.register_craftitem("yatm_bees:brood_comb_empty", {
  description = "Empty Brood Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
    empty_brood_comb = 1,
  },

  inventory_image = "yatm_brood_comb_empty.png",
})

minetest.register_craftitem("yatm_bees:brood_comb_full", {
  description = "Full Brood Comb",

  groups = {
    wax_comb = 1,
    brood_comb = 1
  },

  inventory_image = "yatm_brood_comb_full.png",
})
