--[[

  The Distillation registry, as its name implies is used to register distillation recipes.

  Distillation recipes have 2 outputs: a vapour and a distilled fluid

]]
local DistillationRegistry = foundation.com.Class:extends("DistillationRegistry")
local ic = DistillationRegistry.instance_class

function ic:initialize()
  ic._super.initialize(self)
  self.m_vapour_to_recipe = {}
end

--[[
DistillationRegistry:register_distillation(
  vapour_name :: String.t,
  distilled_fluid_name :: String.t,
  output_vapour_name :: String.t,
  { input_ratio :: integer, distilled_ratio :: integer, vapour_ratio :: integer }
)
]]
function ic:register_distillation_recipe(vapour_name, distilled_fluid_name, output_vapour_name, ratios)
  local recipe = {
    ratios = ratios,
    distilled_fluid_name = distilled_fluid_name,
    output_vapour_name = output_vapour_name,
  }
  self.m_vapour_to_recipe[vapour_name] = recipe
  return self
end

function ic:find_distillation_recipe(vapour_name)
  return self.m_vapour_to_recipe[vapour_name]
end

yatm_refinery.DistillationRegistry = DistillationRegistry
