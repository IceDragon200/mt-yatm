local itemstack_new_blank = assert(yatm_core.itemstack_new_blank)
local itemstack_is_blank = assert(yatm_core.itemstack_is_blank)
local itemstack_take = assert(yatm_core.itemstack_take)
local itemstack_maybe_merge = assert(yatm_core.itemstack_maybe_merge)
local InventoryList = {}

function InventoryList.first_stack(list)
  assert(list, "expected an inventory list")
  for _,item_stack in ipairs(list) do
    if not itemstack_is_blank(item_stack) then
      return item_stack
    end
  end
  return nil
end

function InventoryList.merge_stack(list, stack)
  assert(list, "expected an inventory list")
  local max_stack_size = stack:get_stack_max()
  for i,item_stack in ipairs(list) do
    local new_stack
    if itemstack_is_blank(stack) then
      break
    end
    if itemstack_is_blank(item_stack) then
      new_stack, stack = itemstack_take(stack, max_stack_size)
      list[i] = new_stack
    else
      new_stack, stack = itemstack_maybe_merge(item_stack, stack)
      list[i] = new_stack
    end
  end
  return list, stack
end

function InventoryList.extract_stack(list, stack_or_size)
  assert(list, "expected an inventory list")
  local taken = nil
  if type(stack_or_size) == "number" then
    -- the criteria is any stack with a count
    for i,item_stack in ipairs(list) do
      if item_stack:get_count() > 0 then
        taken = item_stack:peek_item(stack_or_size)
        local new_count = item_stack:get_count() - taken:get_count()
        if new_count == 0 then
          list[i] = itemstack_new_blank()
        else
          list[i] = item_stack:peek_item(new_count)
        end
        break
      end
    end
  else
    -- the criteria is another stack
    for i,item_stack in ipairs(list) do
      -- TODO: proper matching
      if item_stack:get_name() == stack_or_size:get_name() then
        taken = item_stack:peek_item(stack_or_size:get_count())
        local new_count = item_stack:get_count() - taken:get_count()
        if new_count == 0 then
          list[i] = itemstack_new_blank()
        else
          list[i] = item_stack:peek_item(new_count)
        end
        break
      end
    end
  end
  return list, taken
end

yatm_core.InventoryList = InventoryList
