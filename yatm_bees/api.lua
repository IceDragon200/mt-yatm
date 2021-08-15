-- @namespace yatm.bees
yatm.bees = {}

-- Determines if the given item stack is a bee
--
-- @spec itemstack_is_bee(ItemStack): Boolean
function yatm.bees.itemstack_is_bee(item_stack)
  if not item_stack:is_empty() then
    local def = item_stack:get_definition()
    if def then
      if def.groups.bee then
        return true
      end
    end
  end
  return false
end

-- Determines if the given item stack is a bee box frame
--
-- @spec itemstack_is_frame(ItemStack): Boolean
function yatm.bees.itemstack_is_frame(item_stack)
  if not item_stack:is_empty() then
    local def = item_stack:get_definition()
    if def then
      if def.groups.bee_box_frame then
        return true
      end
    end
  end
  return false
end
