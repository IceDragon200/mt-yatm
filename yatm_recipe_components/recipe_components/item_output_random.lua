local WeightedList = assert(foundation.com.WeightedList)
local ItemOutput = assert(yatm.recipe_component.ItemOutput)

--- @namespace yatm.recipe_component

--- @class ItemOutputRandom
local ItemOutputRandom = foundation.com.Class:extends("yatm.recipe_component.ItemOutputRandom")
do
  local ic = ItemOutputRandom.instance_class

  --- @spec #initialize(Table): void
  function ic:initialize(def)
    local items = assert(def.items, "expected a list of items")

    self.items = WeightedList:new()
    self.chance = def.chance or 1.0

    local weight

    for _, item in ipairs(items) do
      weight = item.weight or 1
      item.weight = nil
      self.items:push(ItemOutput:new(item), weight)
    end

    assert(type(self.chance) == "number", "expected chance to be a number")
  end

  --- Generates a new ItemStack based on the value (ignoring the chance factor)
  ---
  --- @spec #make_item_stack_without_chance(): ItemStack
  function ic:make_item_stack_without_chance()
    local base = self.items:random()

    local item_stack = base:make_item_stack()

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

yatm.recipe_component.ItemOutputRandom = ItemOutputRandom
