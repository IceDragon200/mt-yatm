-- Borrowed this from Factorio
yatm_core.register_fluid_nodes("yatm_core:light_oil", {
  description_base = "Light Oil",
  texture_basename = "yatm_light_oil",
  groups = { oil = 1, light_oil = 1, liquid = 3, flammable = 1 },
  alpha = 200,
})

yatm_core.fluids.register("yatm_core:light_oil", {
  groups = {
    oil = 1,
    light_oil = 1,
    flammable = 1,
  },
  node = {
    source = "yatm_core:light_oil_source",
    flowing = "yatm_core:light_oil_flowing",
  },
})

if bucket then
  bucket.register_liquid(
    "yatm_core:light_oil_source",
    "yatm_core:light_oil_flowing",
    "yatm_core:bucket_light_oil",
    "yatm_bucket_light_oil.png",
    "Light Oil Bucket",
    {light_oil_bucket = 1},
    false -- do not replace
  )
end
