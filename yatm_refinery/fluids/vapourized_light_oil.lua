-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_refinery", "vapourized_light_oil", {
  description = "Vapourized Light Oil",

  groups = {
    gas = 1,
    vapour = 1,
    vapourized_light_oil = 1,
  },

  tiles = {
    source = "yatm_vapourized_light_oil_source",
    flowing = "yatm_vapourized_light_oil_flowing",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
