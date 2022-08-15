-- Borrowed this from Factorio
local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "heavy_oil", {
  description = mod.S("Heavy Oil"),

  color = "#ce6300",

  aliases = {
    "yatm_core:heavy_oil",
  },

  groups = {
    liquid = 1,
    oil = 1,
    heavy_oil = 1,
    flammable = 1,
  },

  nodes = {
    texture_basename = "yatm_heavy_oil",
    groups = { oil = 1, heavy_oil = 1, liquid = 3, flammable = 1 },
    use_texture_alpha = "opaque",
    post_effect_color = {a=192, r=200, g=122, b=51},
  },

  bucket = {
    texture = "yatm_bucket_heavy_oil.png",
    groups = { heavy_oil_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
