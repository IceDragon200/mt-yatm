-- Your normal yeast
minetest.register_craftitem("yatm_brewery:yeast_brewers", {
  basename = "yatm_brewery:yeast",

  base_description = "Yeast",

  description = "Brewer's Yeast",

  groups = {
    yeast = 1,
    yeast_brewers = 1,
  },

  inventory_image = "yatm_yeast_brewers.png"
})

-- Wine!
minetest.register_craftitem("yatm_brewery:yeast_bayanus", {
  basename = "yatm_brewery:yeast",

  base_description = "Yeast",

  description = "Bayanus Yeast",

  groups = {
    yeast = 1,
    yeast_bayanus = 1,
  },

  inventory_image = "yatm_yeast_bayanus.png"
})

-- Spicy!
minetest.register_craftitem("yatm_brewery:yeast_scarlet", {
  basename = "yatm_brewery:yeast",

  base_description = "Yeast",

  description = "Scarlet Yeast",

  groups = {
    yeast = 1,
    yeast_scarlet = 1,
  },

  inventory_image = "yatm_yeast_scarlet.png"
})

-- Magical properties, quite frankly, it's weird.
minetest.register_craftitem("yatm_brewery:yeast_umbral", {
  basename = "yatm_brewery:yeast",

  base_description = "Yeast",

  description = "Umbral Yeast",

  groups = {
    yeast = 1,
    yeast_umbral = 1,
  },

  inventory_image = "yatm_yeast_umbral.png"
})
