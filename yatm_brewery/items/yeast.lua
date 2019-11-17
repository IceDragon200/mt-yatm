-- Your normal yeast
minetest.register_craftitem("yatm_brewery:yeast_brewers", {
  description = "Brewer's Yeast",

  groups = {
    yeast = 1,
    yeast_brewers = 1,
  },

  inventory_image = "yatm_yeast_brewers.png"
})

-- Wine!
minetest.register_craftitem("yatm_brewery:yeast_bayanus", {
  description = "Bayanus Yeast",

  groups = {
    yeast = 1,
    yeast_bayanus = 1,
  },

  inventory_image = "yatm_yeast_bayanus.png"
})

-- Spicy!
minetest.register_craftitem("yatm_brewery:yeast_scarlet", {
  description = "Scarlet Yeast",

  groups = {
    yeast = 1,
    yeast_scarlet = 1,
  },

  inventory_image = "yatm_yeast_scarlet.png"
})

-- Magical properties, quite frankly, it's weird.
minetest.register_craftitem("yatm_brewery:yeast_umbral", {
  description = "Umbral Yeast",

  groups = {
    yeast = 1,
    yeast_umbral = 1,
  },

  inventory_image = "yatm_yeast_umbral.png"
})
