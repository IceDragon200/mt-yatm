yatm.fluids.fluid_registry.register("yatm_foundry", "molten_carbon_steel", {
  description = "Molten Carbon Steel",

  groups = {
    molten = 1,
    metal = 1,
    molten_metal = 1,
  },

  tiles = {
    source = "yatm_molten_carbon_steel_source.png",
    flowing = "yatm_molten_carbon_steel_flowing.png",
  },

  fluid_tank = {
    groups = { molten_metal_tank = 1, molten_tank = 1 },
  },
})
