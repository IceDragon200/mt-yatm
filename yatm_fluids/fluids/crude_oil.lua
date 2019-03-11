-- Borrowed this from Factorio
yatm.fluids.FluidRegistry.register("yatm_fluids", "crude_oil", {
  description = "Crude Oil",

  aliases = {
    "yatm_core:oil",
  },

  groups = {
    oil = 1,
    crude_oil = 1,
    flammable = 1,
  },

  nodes = {
    texture_basename = "yatm_crude_oil",
    groups = { oil = 1, crude_oil = 1, liquid = 3, flammable = 1 },
    alpha = 220,
  },

  bucket = {
    texture = "yatm_bucket_oil.png",
    groups = { crude_oil_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
