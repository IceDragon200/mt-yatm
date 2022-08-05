yatm.fluids.fluid_registry.register("default", "water", {
  description = yatm_fluids.S("Water"),

  groups = {
    water = 1,
  },

  fluid_tank = {
    modname = "yatm_fluids"
  },

  nodes = {
    dont_register = true,
    names = {
      source = "default:water_source",
      flowing = "default:water_flowing",
    },
  },
})
