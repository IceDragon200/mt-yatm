-- Borrowed this from Factorio
yatm.fluids.fluid_registry.register("yatm_refinery", "vapourized_light_oil", {
  description = "Vapourized Light Oil",

  color = "#e2e400",

  groups = {
    gas = 1,
    vapourized = 1,
    vapourized_light_oil = 1,
  },

  tiles = {
    source = "yatm_vapourized_light_oil_source.png",
    flowing = "yatm_vapourized_light_oil_flowing.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
