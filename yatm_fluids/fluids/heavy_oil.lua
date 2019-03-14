-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_fluids", "heavy_oil", {
  description = "Heavy Oil",

  aliases = {
    "yatm_core:heavy_oil",
  },

  groups = {
    oil = 1,
    heavy_oil = 1,
    flammable = 1,
  },

  nodes = {
    texture_basename = "yatm_heavy_oil",
    groups = { oil = 1, heavy_oil = 1, liquid = 3, flammable = 1 },
    alpha = 220,
    post_effect_color = {a=192, r=200, g=122, b=51},
  },

  bucket = {
    texture = "yatm_bucket_heavy_oil.png",
    groups = { heavy_oil_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
