--- @namespace yatm.recipe_component

--- @class ItemOutput
local ItemOutput = foundation.com.Class:extends("yatm.recipe_component.ItemOutput")
do
  local ic = ItemOutput.instance_class

  --- @spec #initialize(Table): void
  function ic:initialize(def)
    self.name = assert(def.name, "expected an item name")
    self.min_amount = def.min_amount or 1
    self.max_amount = def.max_amount or def.min_amount or 1
    self.metadata = def.metadata
    self.chance = def.chance or 1.0

    assert(type(self.min_amount) == "number", "expected min_amount to be an integer")
    assert(type(self.max_amount) == "number", "expected max_amount to be an integer")
    assert(type(self.chance) == "number", "expected chance to be a number")
    if self.min_amount < 0 then
      error("expected min_amount to be 0 or more")
    end
    if self.max_amount < 1 then
      error("expected max_amount to be 1 or more")
    end
    if self.min_amount > self.max_amount then
      error("expected min_amount to be less than or equal to max_amount")
    end
    if self.metadata ~= nil then
      assert(type(self.metadata) == "table", "expected metadata to be a table")
    end
  end

  --- Generates a new ItemStack based on the value (ignoring the chance factor)
  ---
  --- @spec #make_item_stack_without_chance(): ItemStack
  function ic:make_item_stack_without_chance()
    local count = self.min_amount
    if count ~= self.max_amount then
      count = self.min_amount + math.random(self.max_amount - self.min_amount)
    end
    local item_stack = ItemStack({
      name = self.name,
      count = count,
    })

    if self.metadata then
      local meta = item_stack:get_meta()

      for key, value in pairs(self.metadata) do
        meta:set(key, value)
      end
    end

    return item_stack
  end

  --- Attempts to make the item stack based on the config, but may also return nil based on the
  --- chance.
  ---
  --- @spec #make_item_stack(): ItemStack | nil
  function ic:make_item_stack()
    if math.random() <= self.chance then
      return self:make_item_stack_without_chance()
    end
    return nil
  end
end

yatm.recipe_component.ItemOutput = ItemOutput
