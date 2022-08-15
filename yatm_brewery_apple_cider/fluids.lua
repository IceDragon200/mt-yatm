yatm.fluids.fluid_registry.register("yatm_brewery_apple_cider", "apple_cider", {
  description = "Apple Cider",

  color = "#FFFFFF",

  groups = {
    apple = 1,
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
