local mod = assert(yatm_brewery_apple_cider)

--- Sweet Cider effectively
yatm.fluids.fluid_registry.register("yatm", "apple_juice", {
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
})

--- Hard Cider
yatm.fluids.fluid_registry.register("yatm", "apple_cider", {
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
})
