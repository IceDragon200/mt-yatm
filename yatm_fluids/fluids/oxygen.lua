local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "oxygen", {
  description = mod.S("Oxygen"),

  color = "#FFFFFF",

  aliases = {
    "yatm_core:oxygen"
  },

  groups = {
    gas = 1,
    oxygen = 1,
  },

  tiles = {
    source = "yatm_oxygen_source.png",
    flowing = "yatm_oxygen_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
