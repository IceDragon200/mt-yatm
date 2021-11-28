-- @namespace yatm_foundry
--
-- The MoldingRegistry contains recipes for the molders
--
-- @class MoldingRegistry
local MoldingRegistry = yatm_core.Class:extends("yatm_foundry.MoldingRegistry")
local ic = assert(MoldingRegistry.instance_class)

-- @spec #initialize(): void
function ic:initialize()
  self.recipes_by_mold = {}
end

-- @spec #register_molding_recipe(
--   name: String,
--   mold_item_stack: ItemStack,
--   result_item_stack: ItemStack,
--   duration: Number
-- ): self
function ic:register_molding_recipe(name, mold_item_stack, molten_fluid, result_item_stack, duration)
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

-- @spec #get_molding_recipe(mold_item_stack: ItemStack, molten_fluid: FluidStack): nil | MoldingRecipe
function ic:get_molding_recipe(mold_item_stack, molten_fluid)
  if mold_item_stack and molten_fluid then
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
  end
  return nil
end

yatm_foundry.MoldingRegistry = MoldingRegistry
