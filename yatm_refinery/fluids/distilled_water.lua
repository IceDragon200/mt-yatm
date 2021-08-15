-- Not sure what I'll use it for, but it exists!
yatm.fluids.fluid_registry.register("yatm_refinery", "distilled_water", {
  description = "Distilled Water",

  groups = {
    liquid = 1,
    water = 1,
    distilled_water = 1,
  },

  tiles = {
    source = "yatm_distilled_water_source.png",
    flowing = "yatm_distilled_water_flowing.png",
  },

  fluid_tank = {
    groups = { fluid_tank = 1, water = 1 },
  },
})
