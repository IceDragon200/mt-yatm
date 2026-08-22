local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "argon", {
  description = mod.S("Argon"),

  color = "#FFFFFF",

  aliases = {
    "yatm_core:argon"
  },

  groups = {
    gas = 1,
    argon = 1,
  },

  tiles = {
    source = "yatm_argon_source.png",
    flowing = "yatm_argon_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
