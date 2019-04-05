--[[
The BlastingRegistry contains recipes for the blast furnaces
]]
local BlastingRegistry = yatm_core.Class:extends()

local m = assert(BlastingRegistry.instance_class)

function m:initialize()
  self.recipes = {}
end

function m:register_blasting_recipe()
  return self
end

yatm_foundry.BlastingRegistry = BlastingRegistry:new()
