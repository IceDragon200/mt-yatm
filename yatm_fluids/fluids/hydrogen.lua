yatm.fluids.fluid_registry.register("yatm_fluids", "hydrogen", {
  description = yatm_fluids.S("Hydrogen"),

  aliases = {
    "yatm_core:hydrogen"
  },

  groups = {
    gas = 1,
    hydrogen = 1,
    water_based = 1,
  },

  tiles = {
    source = "yatm_hydrogen_source.png",
    flowing = "yatm_hydrogen_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
