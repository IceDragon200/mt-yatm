local assertions = assert(foundation.com.assertions)
--- @namespace yatm.recipe_component

--- @class ItemIngredient
local ItemIngredient = foundation.com.Class:extends("yatm.recipe_component.ItemIngredient")
do
  local ic = ItemIngredient.instance_class

  ItemIngredient.ERR_ITEM_OK = "ERR_OK"
  ItemIngredient.ERR_ITEM_NAME_MISMATCH = "ERR_ITEM_NAME_MISMATCH"
  ItemIngredient.ERR_ITEM_STACK_EMPTY = "ERR_ITEM_STACK_EMPTY"
  ItemIngredient.ERR_ITEM_STACK_SMALL = "ERR_ITEM_STACK_SMALL"

  --- @spec #initialize(Table): void
  function ic:initialize(def)
    self.name = assertions.is_string(def.name, "expected an item name")
    self.amount = assertions.is_number(def.amount or 1, "expected amount to be a integer")
    self.metadata = def.metadata
  end

  --- @spec #matches_item_stack(ItemStack): (Boolean, ErrorCode)
  function ic:matches_item_stack(item_stack)
    if not item_stack or item_stack:is_empty() then
      return false, ItemIngredient.ERR_ITEM_STACK_EMPTY
    end

    if item_stack:get_count() < self.amount then
      return false, ItemIngredient.ERR_ITEM_STACK_SMALL
    end

    if item_stack:get_name() ~= self.name then
      return false, ItemIngredient.ERR_ITEM_NAME_MISMATCH
    end

    -- TODO: check metadata

    return true, ItemIngredient.ERR_ITEM_OK
  end
end

yatm.recipe_component.ItemIngredient = ItemIngredient
