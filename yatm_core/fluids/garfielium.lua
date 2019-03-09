-- Don't ask, it's a tribute to my cat
yatm_core.register_fluid_nodes("yatm_core:garfielium", {
  description_base = "Garfielium",
  texture_basename = "yatm_garfielium",
  groups = { oil = 1, garfielium = 1, liquid = 3, explosive = 1 },
})

yatm_core.fluids.register("yatm_core:garfielium", {
  groups = {
    oil = 1,
    garfielium = 1,
    explosive = 1, -- explodes once exposed to air
  },
  node = {
    source = "yatm_core:garfielium_source",
    flowing = "yatm_core:garfielium_flowing",
  },
})

if bucket then
  bucket.register_liquid(
    "yatm_core:garfielium_source",
    "yatm_core:garfielium_flowing",
    "yatm_core:bucket_garfielium",
    "yatm_bucket_garfielium.png",
    "Garfielium Oil Bucket",
    {garfielium_bucket = 1},
    false -- do not replace
  )
end
