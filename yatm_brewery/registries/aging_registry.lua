--
-- The AgingRegistry contains recipes for an aging barrel
--
local AgingRegistry = foundation.com.Class:extends('yatm.brewery.AgingRegistry')
local ic = AgingRegistry.instance_class

function ic:initialize()
  self.m_recipes = {}
end

function ic:register_aging_recipe()
end

yatm_brewery.AgingRegistry = AgingRegistry
