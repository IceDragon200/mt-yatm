local mod = assert(yatm_fluids)

yatm.fluids.fluid_registry.register("yatm_fluids", "sulphur_trioxide", {
  description = mod.S("Sulphur Trioxide"),

  color = "#FFFFFF",

  groups = {
    corrosive = 1,
    gas = 1,
    sulphuric = 1,
    sulphur_trioxide_gas = 1,
  },

  tiles = {
    source = "yatm_sulphur_trioxide_source.png",
    flowing = "yatm_sulphur_trioxide_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
