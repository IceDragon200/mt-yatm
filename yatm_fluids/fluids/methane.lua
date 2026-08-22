local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "methane", {
  description = mod.S("Methane"),

  color = "#FFFFFF",

  aliases = {
    "yatm_core:methane"
  },

  groups = {
    gas = 1,
    methane = 1,
  },

  tiles = {
    source = "yatm_methane_source.png",
    flowing = "yatm_methane_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
