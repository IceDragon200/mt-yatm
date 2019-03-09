-- Borrowed this from Factorio
yatm_core.register_fluid_nodes("yatm_core:heavy_oil", {
  description_base = "Heavy Oil",
  texture_basename = "yatm_heavy_oil",
  groups = { oil = 1, heavy_oil = 1, liquid = 3, flammable = 1 },
  alpha = 220,
})

yatm_core.fluids.register("yatm_core:heavy_oil", {
  groups = {
    oil = 1,
    heavy_oil = 1,
    flammable = 2,
  },
  node = {
    source = "yatm_core:heavy_oil_source",
    flowing = "yatm_core:heavy_oil_flowing",
  },
})

if bucket then
  bucket.register_liquid(
    "yatm_core:heavy_oil_source",
    "yatm_core:heavy_oil_flowing",
    "yatm_core:bucket_heavy_oil",
    "yatm_bucket_heavy_oil.png",
    "Heavy Oil Bucket",
    {heavy_oil_bucket = 1},
    false -- do not replace
  )
end
