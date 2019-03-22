local VapourRegistry = assert(yatm_refinery.VapourRegistry)
local DistillationRegistry = assert(yatm_refinery.DistillationRegistry)

--
-- Vapourizing recipes
--
VapourRegistry:register_vapour("yatm_fluids:crude_oil", "yatm_refinery:vapourized_crude_oil", {})
VapourRegistry:register_vapour("yatm_fluids:heavy_oil", "yatm_refinery:vapourized_heavy_oil", {})
VapourRegistry:register_vapour("yatm_fluids:light_oil", "yatm_refinery:vapourized_light_oil", {})


--
-- Distillation recipes
--

-- vapourized_crude_oil distills back to crude_oil (boring I know), it would have been asphalt or something heavier, but meh.
-- It however vapourizes further into heavy oil
DistillationRegistry:register_distillation(
  "yatm_refinery:vapourized_crude_oil", -- input
  "yatm_fluids:crude_oil", -- distill
  "yatm_refinery:vapourized_heavy_oil", -- new vapour
  { 10, 3, 7 },
)

DistillationRegistry:register_distillation(
  "yatm_refinery:vapourized_heavy_oil", -- input
  "yatm_fluids:heavy_oil", -- distill
  "yatm_refinery:vapourized_light_oil", -- new vapour
  { 10, 4, 6 },
)

DistillationRegistry:register_distillation(
  "yatm_refinery:vapourized_light_oil", -- input
  "yatm_fluids:light_oil", -- distill
  "yatm_refinery:vapourized_light_oil", -- new vapour
  { 10, 10, 0 },
)
