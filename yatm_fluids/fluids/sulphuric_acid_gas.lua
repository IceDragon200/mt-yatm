local mod = assert(yatm_fluids)

yatm.fluids.fluid_registry.register("yatm_fluids", "sulphuric_acid", {
  description = mod.S("Sulphuric Acid Gas"),

  color = "#FFFFFF",

  groups = {
    corrosive = 1,
    gas = 1,
    sulphuric = 1,
    sulphuric_acid_gas = 1,
  },

  tiles = {
    source = "yatm_sulphuric_acid_gas_source.png",
    flowing = "yatm_sulphuric_acid_gas_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
