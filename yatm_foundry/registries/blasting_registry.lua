--
-- The BlastingRegistry contains recipes for the blast furnaces
--
local BlastingRegistry = foundation.com.Class:extends("BlastingRegistry")

local m = assert(BlastingRegistry.instance_class)

function m:initialize()
  self.recipes = {}
end

function m:register_blasting_recipe()
  return self
end

yatm_foundry.BlastingRegistry = BlastingRegistry
