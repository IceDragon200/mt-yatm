yatm.fluids.fluid_registry.register("yatm_foundry", "molten_gold", {
  description = "Molten Gold",

  groups = {
    molten = 1,
    metal = 1,
    molten_metal = 1,
  },

  tiles = {
    source = "yatm_molten_gold_source.png",
    flowing = "yatm_molten_gold_flowing.png",
  },

  fluid_tank = {
    groups = { molten_metal_tank = 1, molten_tank = 1 },
  },
})
