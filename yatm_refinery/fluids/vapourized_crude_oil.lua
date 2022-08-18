-- Borrowed this from Factorio
yatm.fluids.fluid_registry.register("yatm_refinery", "vapourized_crude_oil", {
  description = "Vapourized Crude Oil",

  color = "#1a1c1d",

  groups = {
    gas = 1,
    vapourized = 1,
    vapourized_crude_oil = 1,
  },

  tiles = {
    source = "yatm_vapourized_crude_oil_source.png",
    flowing = "yatm_vapourized_crude_oil_flowing.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
