minetest.register_craftitem("yatm_bees:honey_comb_empty", {
  description = "Empty Honey Comb",

  groups = {
    wax_comb = 1,
    empty_comb = 1,
    empty_honey_comb = 1,
  },

  inventory_image = "yatm_honey_comb_empty.png",
})

minetest.register_craftitem("yatm_bees:honey_comb_full", {
  description = "Full Honey Comb",

  groups = {
    wax_comb = 1,
    honey_comb = 1
  },

  inventory_image = "yatm_honey_comb_full.png",
})
