local mod = assert(yatm_fluids)

yatm.fluids.fluid_registry.register("yatm_fluids", "hydrogen_sulphide", {
  description = mod.S("Hydrogen Sulphide"),

  color = "#FFFFFF",

  groups = {
    corrosive = 1,
    gas = 1,
    sulphuric = 1,
    hydrogen_sulphide_gas = 1,
  },

  tiles = {
    source = "yatm_hydrogen_sulphide_source.png",
    flowing = "yatm_hydrogen_sulphide_source.png",
  },

  fluid_tank = {
    groups = { gas_tank = 1 },
  },
})
