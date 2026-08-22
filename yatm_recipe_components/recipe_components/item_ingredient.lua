local assertions = assert(foundation.com.assertions)
local table_deep_copy = assert(foundation.com.table_deep_copy)

--- @namespace yatm.recipe_component

--- @class ItemIngredient
local ItemIngredient = foundation.com.Class:extends("yatm.recipe_component.ItemIngredient")
do
  local ic = ItemIngredient.instance_class

  ItemIngredient.ERR_ITEM_OK = "ERR_OK"
  ItemIngredient.ERR_ITEM_NAME_MISMATCH = "ERR_ITEM_NAME_MISMATCH"
  ItemIngredient.ERR_ITEM_STACK_EMPTY = "ERR_ITEM_STACK_EMPTY"
  ItemIngredient.ERR_ITEM_STACK_SMALL = "ERR_ITEM_STACK_SMALL"

  --- @spec #initialize(String | Table): void
  function ic:initialize(def)
    --- The item's full name, in the form "domain:local" (e.g. yatm_brewery:apple)
    ---
    --- @member name: String

    --- To be consistent with FluidIngredient, amount acts as the item count
    ---
    --- @member amount: Integer

    --- Optional item metadata
    ---
    --- @member metadata: Table
    if type(def) == "table" then
      self.name = assertions.is_string(def.name, "expected an item name")
      self.amount = assertions.is_number(def.amount or 1, "expected amount to be a integer")
      self.metadata = def.metadata
    elseif type(def) == "string" then
      local name, amount
      name, amount = def:match("(%g+:%g+)%s+(%d+)")

      if not name then
        amount = 1
        name = def:match("(%g+:%g+)")
      end

      self.name = assertions.is_string(name, "expected an item name")
      self.amount = tonumber(amount)
      self.metadata = nil
    else
      error("expected def to be String or Table")
    end
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

  --- @spec #make_item_stack(): ItemStack
  function ic:make_item_stack()
    return ItemStack({
      name = self.name,
      count = self.amount,
      metadata = table_deep_copy(self.metadata),
    })
  end
end

yatm.recipe_component.ItemIngredient = ItemIngredient
