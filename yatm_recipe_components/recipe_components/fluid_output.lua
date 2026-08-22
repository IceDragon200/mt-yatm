local assertions = assert(foundation.com.assertions)
local FluidStack = assert(yatm.fluids.FluidStack)
--- @namespace yatm.recipe_component

--- @class FluidOutput
local FluidOutput = foundation.com.Class:extends("yatm.recipe_component.FluidOutput")
do
  local ic = FluidOutput.instance_class

  --- @spec #initialize(Table): void
  function ic:initialize(def)
    self.name = assertions.is_string(def.name, "expected a fluid name")
    self.min_amount = assertions.is_number(def.min_amount or 1,
      "expected min_amount to be an integer")
    self.max_amount = assertions.is_number(def.max_amount or def.min_amount or 1,
      "expected max_amount to be an integer")
    self.chance = assertions.is_number(def.chance or 1.0,
      "expected chance to be a number")

    if self.min_amount < 0 then
      error("expected min_amount to be 0 or more")
    end
    if self.max_amount < 1 then
      error("expected max_amount to be 1 or more")
    end
    if self.min_amount > self.max_amount then
      error("expected min_amount to be less than or equal to max_amount")
    end
  end

  --- Generates a new FluidStack based on the value (ignoring the chance factor)
  ---
  --- @spec #make_fluid_stack_without_chance(): FluidStack
  function ic:make_fluid_stack_without_chance()
    local amount = self.min_amount
    if amount ~= self.max_amount then
      amount = self.min_amount + math.random(self.max_amount - self.min_amount)
    end
    local fluid_stack = FluidStack.new(self.name, amount)

    return fluid_stack
  end

  --- Attempts to make the item stack based on the config, but may also return nil based on the
  --- chance.
  ---
  --- @spec #make_fluid_stack(): FluidStack | nil
  function ic:make_fluid_stack()
    if math.random() <= self.chance then
      return self:make_fluid_stack_without_chance()
    end
    return nil
  end
end

yatm.recipe_component.FluidOutput = FluidOutput
