yatm.fluids.FluidRegistry.register("default", "lava", {
  description = "Lava",

  groups = {
    lava = 1,
  },

  nodes = {
    dont_register = true,
    names = {
      source = "default:lava_source",
      flowing = "default:lava_flowing",
    },
  },

  fluid_tank = {
    modname = "yatm_fluids",
    light_source = 12,
  },
})
