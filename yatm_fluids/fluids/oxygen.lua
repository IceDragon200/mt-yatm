yatm.fluids.fluid_registry.register("yatm_fluids", "oxygen", {
  description = yatm_fluids.S("oxygen"),

  aliases = {
    "yatm_core:oxygen"
  },

  groups = {
    gas = 1,
    oxygen = 1,
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
