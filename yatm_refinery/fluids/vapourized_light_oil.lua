-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_refinery", "vapourized_light_oil", {
  description = "Vapourized Light Oil",

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
