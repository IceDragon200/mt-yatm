yatm.fluids.FluidRegistry.register("yatm_foundry", "molten_tin", {
  description = "Molten Tin",

  groups = {
    molten = 1,
    metal = 1,
    molten_metal = 1,
  },

  tiles = {
    source = "yatm_molten_tin_source",
    flowing = "yatm_molten_tin_flowing",
  },

  fluid_tank = {
    groups = { molten_metal_tank = 1, molten_tank = 1 },
  },
})
