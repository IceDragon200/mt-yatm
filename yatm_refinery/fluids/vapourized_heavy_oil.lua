-- Borrowed this from Factorio
yatm.fluids.fluid_registry.register("yatm_refinery", "vapourized_heavy_oil", {
  description = "Vapourized Heavy Oil",

  color = "#ce6300",

  groups = {
    gas = 1,
    vapourized = 1,
    vapourized_heavy_oil = 1,
  },

  tiles = {
    source = "yatm_vapourized_heavy_oil_source.png",
    flowing = "yatm_vapourized_heavy_oil_flowing.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
