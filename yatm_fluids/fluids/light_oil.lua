-- Borrowed this from Factorio
local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "light_oil", {
  description = mod.S("Light Oil"),

  color = "#e2e400",

  attributes = {
    fuel = {
      energy_per_unit = 20,
    },
  },

  aliases = {
    "yatm_core:light_oil",
  },

  groups = {
    liquid = 1,
    oil = 1,
    light_oil = 1,
    flammable = 1,
    combustable = 1,
  },

  nodes = {
    texture_basename = "yatm_light_oil",
    groups = { oil = 1, light_oil = 1, liquid = 3, flammable = 1 },

    use_texture_alpha = "opaque",
    post_effect_color = {a=192, r=216, g=197, b=69},
  },

  bucket = {
    texture = true,
    groups = { light_oil_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
