--[[

  The Vapour registry, as its name implies is used to register 'vapour'-ized recipes.

  The vapour in question is treated as a normal fluid, so register it there first.

  Note currently vapour > fluid is a 1:1 mapping, both back and forth, this may change in the future, if I feel so inclined.

]]
local VapourRegistry = foundation.com.Class:extends("VapourRegistry")
local ic = VapourRegistry.instance_class

function ic:initialize()
  ic._super.initialize(self)
  self.m_fluid_name_to_recipe = {}
  self.m_vapour_name_to_recipe = {}
end

function ic:register_vapour(fluid_name, vapour_name, data)
  local recipe = {
    vapour_name = vapour_name,
    fluid_name = fluid_name,
    data = data or {}
  }

  self.m_fluid_name_to_recipe[fluid_name] = recipe
  self.m_vapour_name_to_recipe[vapour_name] = recipe
  return self
end

function ic:find_recipe_for_fluid(fluid_name)
  return self.m_fluid_name_to_recipe[fluid_name]
end

yatm_refinery.VapourRegistry = VapourRegistry
