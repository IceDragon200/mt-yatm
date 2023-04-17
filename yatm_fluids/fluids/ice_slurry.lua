local mod = yatm_fluids

yatm.fluids.fluid_registry.register("yatm_fluids", "ice_slurry", {
  description = mod.S("Ice Slurry"),

  color = "#6ed3ea",

  groups = {
    liquid = 1,
    ice = 1,
    ice_slurry = 1,
    freezing = 1,
  },

  nodes = {
    texture_basename = "yatm_ice_slurry",
    groups = { ice = 1, ice_slurry = 1, liquid = 3, freezing = 2 },
    use_texture_alpha = "opaque",
    post_effect_color = {a=192, r=167, g=231, b=216},
  },

  bucket = {
    texture = true,
    groups = { ice_slurry_bucket = 1, freezing = 1 },
    force_renew = false,
  },

  fluid_tank = {
    groups = { freezing = 1 },
  },
})
