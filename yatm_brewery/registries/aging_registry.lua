local AgingRegistry = yatm_core.Class:extends()
local ic = AgingRegistry.instance_class

function ic:initialize()
  self.m_recipes = {}
end

function ic:register_aging_recipe()
end

yatm_brewery.AgingRegistry = AgingRegistry
