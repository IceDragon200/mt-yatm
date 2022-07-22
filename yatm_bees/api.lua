-- @namespace yatm.bees
yatm.bees = {
  bait_catches_registry = yatm_bees.BaitCatchesRegistry:new(),
}

-- Determines if the given item stack is a bee of some kind
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

-- Determines if the given item stack is a bee queen
--
-- @spec itemstack_is_bee_worker(ItemStack): Boolean
function yatm.bees.itemstack_is_bee_worker(item_stack)
  if not item_stack:is_empty() then
    local def = item_stack:get_definition()
    if def then
      if def.groups.bee and def.groups.bee_worker then
        return true
      end
    end
  end
  return false
end

-- Determines if the given item stack is a bee queen
--
-- @spec itemstack_is_bee_princess(ItemStack): Boolean
function yatm.bees.itemstack_is_bee_princess(item_stack)
  if not item_stack:is_empty() then
    local def = item_stack:get_definition()
    if def then
      if def.groups.bee and def.groups.bee_princess then
        return true
      end
    end
  end
  return false
end

-- Determines if the given item stack is a bee queen
--
-- @spec itemstack_is_bee_queen(ItemStack): Boolean
function yatm.bees.itemstack_is_bee_queen(item_stack)
  if not item_stack:is_empty() then
    local def = item_stack:get_definition()
    if def then
      if def.groups.bee and def.groups.bee_queen then
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
