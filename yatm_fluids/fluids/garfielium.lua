-- Don't ask, it's a tribute to my cat
yatm.fluids.fluid_registry.register("yatm_fluids", "garfielium", {
  description = "Garfielium",

  aliases = {
    "yatm_core:garfielium",
  },

  groups = {
    oil = 1,
    garfielium = 1,
    explosive = 1,
    combustable = 1,
  },

  nodes = {
    texture_basename = "yatm_garfielium",
    groups = { liquid = 3, oil = 1, garfielium = 1, explosive = 1, combustable = 1 },
    post_effect_color = {a=192, r=223, g=136, b=57},
  },

  bucket = {
    texture = "yatm_bucket_garfielium.png",
    groups = {
      garfielium_bucket = 1,
    },
    force_renew = false,
  },

  fluid_tank = {},
})
