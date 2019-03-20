-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_refinery", "vapourized_heavy_oil", {
  description = "Vapourized Heavy Oil",

  groups = {
    gas = 1,
    vapour = 1,
    vapourized_heavy_oil = 1,
  },

  tiles = {
    source = "yatm_vapourized_heavy_oil_source",
    flowing = "yatm_vapourized_heavy_oil_flowing",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
