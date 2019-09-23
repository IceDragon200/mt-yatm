minetest.register_craft({
  output = "yatm_core:dust_bronze 4",
  type = "shapeless",
  recipe = {
    "yatm_core:dust_tin",
    "yatm_core:dust_copper",
    "yatm_core:dust_copper",
    "yatm_core:dust_copper",
  }
})

minetest.register_craft({
  output = "yatm_core:dust_electrum 2",
  type = "shapeless",
  recipe = {
    "yatm_core:dust_gold",
    "yatm_core:dust_silver",
  }
})
