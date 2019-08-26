--[[

  AKA. fake honey, can't be eaten, but can be used as a substitute for some recipes.

]]
yatm.fluids.FluidRegistry.register("yatm_bees", "synthetic_honey", {
  description = "Synthetic Honey",

  groups = {
    synthetic_honey = 1,
    honey_like = 1,
  },

  nodes = {
    texture_basename = "yatm_synthetic_honey",
    groups = { synthetic_honey = 1, honey_like = 1, liquid = 3 },
    alpha = 255,
    post_effect_color = {a=192, r=223, g=136, b=57},
  },

  bucket = {
    texture = "yatm_bucket_synthetic_honey.png",
    groups = { synthetic_honey_bucket = 1, honey_like_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
