-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_fluids", "light_oil", {
  description = "Light Oil",

  aliases = {
    "yatm_core:light_oil",
  },

  groups = {
    oil = 1,
    light_oil = 1,
    flammable = 1,
    combustable = 1,
  },

  nodes = {
    texture_basename = "yatm_light_oil",
    groups = { oil = 1, light_oil = 1, liquid = 3, flammable = 1 },
    alpha = 220,
  },

  bucket = {
    texture = "yatm_bucket_light_oil.png",
    groups = { light_oil_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
