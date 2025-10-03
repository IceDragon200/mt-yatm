local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "nitrogen", {
  description = mod.S("Nitrogen"),

  color = "#FFFFFF",

  aliases = {
    "yatm_core:nitrogen"
  },

  groups = {
    gas = 1,
    nitrogen = 1,
  },

  tiles = {
    source = "yatm_nitrogen_source.png",
    flowing = "yatm_nitrogen_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
