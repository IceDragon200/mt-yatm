--[[
The SmeltingRegistry contains recipes for the smelter
]]
local SmeltingRegistry = yatm_core.Class:extends()

local m = assert(SmeltingRegistry.instance_class)

function m:initialize()
  self.recipes = {}
end

function m:register_smelting_recipe(name, source_item_stack, results, duration)
  local item_stack_name = source_item_stack:get_name()
  self.recipes[item_stack_name] = {
    name = name,
    source_item_stack = source_item_stack,
    results = results,
    duration = duration,
  }
  return self
end

function m:get_smelting_recipe(item_stack)
  local item_stack_name = item_stack:get_name()
  local recipe = self.recipes[item_stack_name]
  if recipe then
    if recipe.source_item_stack:get_count() <= item_stack:get_count() then
      return recipe
    end
  end
  return nil
end

yatm_foundry.SmeltingRegistry = SmeltingRegistry:new()
