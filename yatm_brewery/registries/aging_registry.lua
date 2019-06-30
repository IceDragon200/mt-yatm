local AgingRegistry = yatm_core.Class:extends()
local ic = AgingRegistry.instance_class

function ic:initialize()
  self.recipes = {}
end

function ic:register_aging_recipe()
end

yatm_brewery.aging_registry = AgingRegistry:new()
