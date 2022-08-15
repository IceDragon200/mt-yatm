-- Borrowed this from Factorio
local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "crude_oil", {
  description = mod.S("Crude Oil"),

  color = "#1a1c1d",

  aliases = {
    "yatm_core:oil",
  },

  groups = {
    liquid = 1,
    oil = 1,
    crude_oil = 1,
    flammable = 1,
  },

  nodes = {
    texture_basename = "yatm_crude_oil",
    groups = { oil = 1, crude_oil = 1, liquid = 3, flammable = 1 },
    use_texture_alpha = "opaque",
    post_effect_color = {a=192, r=51, g=61, b=73},
  },

  bucket = {
    texture = "yatm_bucket_oil.png",
    groups = { crude_oil_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
