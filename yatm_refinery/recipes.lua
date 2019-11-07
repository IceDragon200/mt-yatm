local FluidStack = assert(yatm.fluids.FluidStack)
local vapour_registry = assert(yatm.refinery.vapour_registry)
local distillation_registry = assert(yatm.refinery.distillation_registry)
local condensing_registry = assert(yatm.condensing.condensing_registry)

--
-- Condensing Registry
--
-- Condensation recipes provide a way to quickly obtain oils, at the cost of not
-- reaching the next distillation stage.
local reg = condensing_registry:method("register_condensing_recipe")

reg("yatm_refinery:condense_crude_oil",
    FluidStack.new("yatm_refinery:vapourized_crude_oil", 100),
    FluidStack.new("yatm_fluids:crude_oil", 100),
    5.0)

reg("yatm_refinery:condense_heavy_oil",
    FluidStack.new("yatm_refinery:vapourized_heavy_oil", 100),
    FluidStack.new("yatm_fluids:heavy_oil", 100),
    5.0)

reg("yatm_refinery:condense_light_oil",
    FluidStack.new("yatm_refinery:vapourized_light_oil", 100),
    FluidStack.new("yatm_fluids:light_oil", 100),
    5.0)

--
-- Vapourizing recipes
--
local reg = vapour_registry:method("register_vapour")

reg("yatm_fluids:crude_oil", "yatm_refinery:vapourized_crude_oil", {})
reg("yatm_fluids:heavy_oil", "yatm_refinery:vapourized_heavy_oil", {})
reg("yatm_fluids:light_oil", "yatm_refinery:vapourized_light_oil", {})

--
-- Distillation recipes
--

-- vapourized_crude_oil distills back to crude_oil (boring I know), it would have been asphalt or something heavier, but meh.
-- It however vapourizes further into heavy oil
local reg = distillation_registry:method("register_distillation_recipe")

-- Oils
reg(
  "yatm_refinery:vapourized_crude_oil", -- input
  "yatm_fluids:crude_oil", -- distill
  "yatm_refinery:vapourized_heavy_oil", -- new vapour
  { 10, 3, 7 }
)

reg(
  "yatm_refinery:vapourized_heavy_oil", -- input
  "yatm_fluids:heavy_oil", -- distill
  "yatm_refinery:vapourized_light_oil", -- new vapour
  { 10, 4, 6 }
)

reg(
  "yatm_refinery:vapourized_light_oil", -- input
  "yatm_fluids:light_oil", -- distill
  "yatm_refinery:vapourized_light_oil", -- new vapour
  { 10, 10, 0 }
)

-- Distilled Water
reg(
  "yatm_fluids:steam", -- input
  "yatm_refinery:distilled_water", -- distill
  "yatm_fluids:steam", -- new vapour
  { 10, 10, 0 }
)
