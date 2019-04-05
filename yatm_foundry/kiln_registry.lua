--[[
The KilnRegistry contains recipes for the kiln
]]
local KilnRegistry = yatm_core.Class:extends()

local m = assert(KilnRegistry.instance_class)

function m:initialize()
  self.recipes = {}
end

function m:register_drying_recipe()
end

yatm_foundry.KilnRegistry = KilnRegistry:new()
