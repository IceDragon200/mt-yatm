local mod = assert(yatm_fluids)

yatm.fluids.fluid_registry.register("yatm_fluids", "sulphur_dioxide", {
  description = mod.S("Sulphur Dioxide"),

  color = "#FFFFFF",

  groups = {
    corrosive = 1,
    gas = 1,
    sulphuric = 1,
    sulphur_dioxide_gas = 1,
  },

  tiles = {
    source = "yatm_sulphur_dioxide_source.png",
    flowing = "yatm_sulphur_dioxide_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
