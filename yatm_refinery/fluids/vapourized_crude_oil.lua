-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_refinery", "vapourized_crude_oil", {
  description = "Vapourized Crude Oil",

  groups = {
    gas = 1,
    vapour = 1,
    vapourized_crude_oil = 1,
  },

  tiles = {
    source = "yatm_vapourized_crude_oil_source",
    flowing = "yatm_vapourized_crude_oil_flowing",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
