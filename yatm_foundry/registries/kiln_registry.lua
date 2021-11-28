--
-- The KilnRegistry contains recipes for the kiln
--
local KilnRegistry = foundation.com.Class:extends("KilnRegistry")
local ic = assert(KilnRegistry.instance_class)

function ic:initialize()
  self.recipes = {}
end

function ic:register_drying_recipe()
end

yatm_foundry.KilnRegistry = KilnRegistry
