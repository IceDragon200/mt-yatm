-- Borrowed this from Factorio
yatm_core.register_fluid_nodes("yatm_core:oil", {
  description_base = "Crude Oil",
  texture_basename = "yatm_oil",
  groups = { oil = 1, crude_oil = 1, liquid = 3, flammable = 1 },
  alpha = 255,
})

yatm_core.fluids.register("yatm_core:oil", {
  groups = {
    oil = 1,
    crude_oil = 1,
    flammable = 3, -- the higher the number, the slower it burns
  },
  node = {
    source = "yatm_core:oil_source",
    flowing = "yatm_core:oil_flowing",
  },
})

if bucket then
  bucket.register_liquid(
    "yatm_core:oil_source",
    "yatm_core:oil_flowing",
    "yatm_core:bucket_oil",
    "yatm_bucket_oil.png",
    "Oil Bucket",
    {oil_bucket = 1},
    false -- do not replace
  )
end
