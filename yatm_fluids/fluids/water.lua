yatm.fluids.FluidRegistry.register("default", "water", {
  description = "Water",

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
