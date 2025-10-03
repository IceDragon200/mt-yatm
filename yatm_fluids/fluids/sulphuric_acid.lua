local mod = assert(yatm_fluids)

yatm.fluids.fluid_registry.register("yatm_fluids", "sulphuric_acid", {
  description = mod.S("Sulphuric Acid"),

  color = "#FFFFFF",

  groups = {
    corrosive = 1,
    liquid = 1,
    sulphuric = 1,
    sulphuric_acid_liquid = 1,
  },

  tiles = {
    source = "yatm_sulphuric_acid_source.png",
    flowing = "yatm_sulphuric_acid_source.png",
  },

  fluid_tank = {
    groups = { liquid_tank = 1 },
  },
})
