--[[

  AKA. fake honey, can't be eaten, but can be used as a substitute for some recipes.

]]
yatm.fluids.fluid_registry.register("yatm_bees", "synthetic_honey", {
  description = "Synthetic Honey",

  color = "#ff9c16",

  groups = {
    synthetic_honey = 1,
    honey_like = 1,
  },

  nodes = {
    texture_basename = "yatm_synthetic_honey",
    groups = { synthetic_honey = 1, honey_like = 1, liquid = 3 },
    use_texture_alpha = "opaque",
    post_effect_color = {a=192, r=223, g=136, b=57},
  },

  bucket = {
    texture = true,
    groups = { synthetic_honey_bucket = 1, honey_like_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
