local FluidStack = assert(yatm.fluids.FluidStack)
--- @namespace yatm.recipe_component

--- @class FluidIngredient
local FluidIngredient = foundation.com.Class:extends("yatm.recipe_component.FluidIngredient")
do
  local ic = FluidIngredient.instance_class

  FluidIngredient.ERR_FLUID_OK = "ERR_OK"
  FluidIngredient.ERR_FLUID_NAME_MISMATCH = "ERR_FLUID_NAME_MISMATCH"
  FluidIngredient.ERR_FLUID_STACK_EMPTY = "ERR_FLUID_STACK_EMPTY"
  FluidIngredient.ERR_FLUID_STACK_SMALL = "ERR_FLUID_STACK_SMALL"

  --- @spec #initialize(Table): void
  function ic:initialize(def)
    self.name = assert(def.name, "expected a fluid name")
    self.amount = def.amount or 1

    assert(type(self.amount) == "number", "expected amount to be a integer")
  end

  --- @spec #matches_fluid_stack(FluidStack): (Boolean, ErrorCode)
  function ic:matches_fluid_stack(fluid_stack)
    if not fluid_stack or FluidStack.is_empty(fluid_stack) then
      return false, FluidIngredient.ERR_FLUID_STACK_EMPTY
    end

    if fluid_stack:get_count() < self.amount then
      return false, FluidIngredient.ERR_FLUID_STACK_SMALL
    end

    if fluid_stack:get_name() ~= self.name then
      return false, FluidIngredient.ERR_FLUID_NAME_MISMATCH
    end

    -- TODO: check metadata

    return true, ItemIngredient.ERR_FLUID_OK
  end
end

yatm.recipe_component.FluidIngredient = FluidIngredient
