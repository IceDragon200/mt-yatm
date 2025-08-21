local mod = assert(yatm_brewery_apple_cider)

--- Sweet Cider effectively
yatm.fluids.fluid_registry.register("yatm_brewery_apple_cider", "apple_juice", {
  description = mod.S("Apple Juice"),

  color = "#D2B48C",

  groups = {
    flavor_apple = 1,
    juice = 1,
  },

  tiles = {
    source = "yatm_apple_cider_source.png",
    flowing = "yatm_apple_cider_flowing.png",
  },

  fluid_tank = {
    groups = { juice_tank = 1 },
  },

  nodes = {
    texture_basename = "yatm_apple_juice",
    groups = {
      juice = 1,
      flavor_apple = 1,
      liquid = 3,
    },
    use_texture_alpha = "opaque",
    post_effect_color = {
      a = 192,
      r = 51,
      g = 61,
      b = 73,
    },
  },

  bucket = {
    texture = true,
    groups = { juice_bucket = 1, apple_juice_bucket = 1 },
    force_renew = false,
  },
})

--- Hard Cider
yatm.fluids.fluid_registry.register("yatm_brewery_apple_cider", "apple_cider", {
  description = mod.S("Apple Cider"),

  color = "#966F33",

  groups = {
    flavor_apple = 1,
    alcoholic = 1,
    cider = 1,
    booze = 1,
  },

  tiles = {
    source = "yatm_apple_cider_source.png",
    flowing = "yatm_apple_cider_flowing.png",
  },

  fluid_tank = {
    groups = { alcoholic_tank = 1, booze_tank = 1 },
  },

  nodes = {
    texture_basename = "yatm_apple_cider",
    groups = {
      juice = 1,
      flavor_apple = 1,
      liquid = 3,
    },
    use_texture_alpha = "opaque",
    post_effect_color = {
      a = 192,
      r = 51,
      g = 61,
      b = 73,
    },
  },

  bucket = {
    texture = true,
    groups = { alcoholic_bucket = 1, booze_bucket = 1, apple_cider_bucket = 1 },
    force_renew = false,
  },
})
