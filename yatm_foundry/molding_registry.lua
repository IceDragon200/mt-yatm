--[[
The MoldingRegistry contains recipes for the molders
]]
local MoldingRegistry = yatm_core.Class:extends()

local m = assert(MoldingRegistry.instance_class)

function m:initialize()
  self.recipes_by_mold = {}
end

function m:register_molding_recipe(name, mold_item_stack, molten_fluid, result_item_stack, duration)
  local mold_name = mold_item_stack:get_name()

  self.recipes_by_mold[mold_name] = self.recipes_by_mold[mold_name] or {}
  local mold_recipes = self.recipes_by_mold[mold_name]
  mold_recipes[molten_fluid.name] = {
    name = name,
    mold_item_stack = mold_item_stack,
    molten_fluid = molten_fluid,
    result_item_stack = result_item_stack,
    duration = duration
  }
  return self
end

function m:get_molding_recipe(mold_item_stack, molten_fluid)
  local mold_name = mold_item_stack:get_name()

  local mold_recipes = self.recipes_by_mold[mold_name]
  if mold_recipes then
    local recipe = mold_recipes[molten_fluid.name]
    if recipe then
      if recipe.molten_fluid.amount <= molten_fluid.amount then
        return recipe
      end
    end
  end
  return nil
end

yatm_foundry.MoldingRegistry = MoldingRegistry:new()
