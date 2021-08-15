--[[

  The real McCoy.

]]
yatm.fluids.fluid_registry.register("yatm_bees", "honey", {
  description = "Honey",

  groups = {
    honey = 1,
    honey_like = 1,
  },

  nodes = {
    texture_basename = "yatm_honey",
    groups = { honey = 1, honey_like = 1, liquid = 3 },
    alpha = 255,
    post_effect_color = {a=192, r=223, g=136, b=57},
  },

  bucket = {
    texture = "yatm_bucket_honey.png",
    groups = { honey_bucket = 1, honey_like_bucket = 1 },
    force_renew = false,
  },

  fluid_tank = {},
})
