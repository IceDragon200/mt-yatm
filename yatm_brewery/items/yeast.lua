local mod = assert(yatm_brewery)

-- Your normal yeast
mod:register_craftitem("yeast_brewers", {
  basename = mod:make_name("yeast"),

  base_description = mod.S("Yeast"),

  description = mod.S("Brewer's Yeast"),

  groups = {
    yeast = 1,
    yeast_brewers = 1,
  },

  inventory_image = "yatm_yeast_brewers.png"
})

-- Wine!
mod:register_craftitem("yeast_bayanus", {
  basename = mod:make_name("yeast"),

  base_description = mod.S("Yeast"),

  description = mod.S("Bayanus Yeast"),

  groups = {
    yeast = 1,
    yeast_bayanus = 1,
  },

  inventory_image = "yatm_yeast_bayanus.png"
})

-- Spicy!
mod:register_craftitem("yeast_scarlet", {
  basename = mod:make_name("yeast"),

  base_description = mod.S("Yeast"),

  description = mod.S("Scarlet Yeast"),

  groups = {
    yeast = 1,
    yeast_scarlet = 1,
  },

  inventory_image = "yatm_yeast_scarlet.png"
})

-- Magical properties, quite frankly, it's weird.
mod:register_craftitem("yeast_umbral", {
  basename = mod:make_name("yeast"),

  base_description = mod.S("Yeast"),

  description = mod.S("Umbral Yeast"),

  groups = {
    yeast = 1,
    yeast_umbral = 1,
  },

  inventory_image = "yatm_yeast_umbral.png"
})
