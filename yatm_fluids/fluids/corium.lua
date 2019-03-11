yatm.fluids.FluidRegistry.register("yatm_fluids", "corium", {
  description = "Corium",

  groups = {
    corium = 1,
    radioactive = 1,
    corrosive = 1,
  },

  nodes = {
    texture_basename = "yatm_corium",
    groups = { corium = 1, radioactive = 1, corrosive = 1 },
    alpha = 220,
  },

  bucket = {
    texture = "yatm_bucket_corium.png",
    groups = { corium_bucket = 1, radioactive = 1, corrosive = 1 },
    force_renew = false,
  },

  fluid_tank = {
    -- The fluid tank is radioactive and gives off mild light
    groups = { radioactive = 1, corrosive = 1 },
    light_source = 10,
  },
})
