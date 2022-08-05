yatm.fluids.fluid_registry.register("default", "river_water", {
  description = yatm_fluids.S("River Water"),

  groups = {
    water = 1,
    river_water = 1,
  },

  nodes = {
    dont_register = true,
    names = {
      source = "default:river_water_source",
      flowing = "default:river_water_flowing",
    },
  },

  fluid_tank = {
    modname = "yatm_fluids"
  },
})
