function yatm_core.itemstack_is_blank(stack)
  if stack then
    -- return yatm_core.is_blank(stack:get_name()) or stack:get_count() == 0
    return stack:is_empty()
  else
    return true
  end
end

function yatm_core.itemstack_copy(stack)
  return stack:peek_item(stack:get_count())
end

function yatm_core.itemstack_get_itemdef(stack)
  if not yatm_core.itemstack_is_blank(stack) then
    local name = stack:get_name()
    return minetest.registered_items[name]
  end
  return nil
end

function yatm_core.itemstack_inspect(stack)
  if stack then
    return "stack[" .. stack:get_name() .. "/" .. stack:get_count() .. "]"
  else
    return "nil"
  end
end

function yatm_core.itemstack_new_blank()
  return ItemStack({
    name = "",
    count = 0,
    wear = 0
  })
end

-- A non-destructive version of ItemStack#take_item,
-- this will return the taken stack as the first value and the remaining as the second
function yatm_core.itemstack_take(stack, length)
  local max = stack:get_count()
  local takable = math.min(length, max)
  if takable == max then
    return stack, yatm_core.itemstack_new_blank()
  else
    return stack:peek_item(takable), stack:peek_item(max - takable)
  end
end

function yatm_core.itemstack_maybe_merge(base_stack, merging_stack)
  local result = base_stack:peek_item(base_stack:get_count())
  local leftover = result:add_item(merging_stack)
  return result, leftover
end

local function assert_itemstack_meta(itemstack)
  if not itemstack or not itemstack.get_meta then
    error("expected an itemstack with get_meta function (got " .. dump(itemstack) .. ")")
  end
end

function yatm_core.get_itemstack_description(itemstack)
  assert_itemstack_meta(itemstack)
  local desc = itemstack:get_meta():get_string("description")
  if yatm_core.is_blank(desc) then
    local itemdef = itemstack:get_definition()
    return itemdef.description or itemstack:get_name()
  else
    return desc
  end
end

function yatm_core.set_itemstack_meta_description(itemstack, description)
  assert_itemstack_meta(itemstack)
  itemstack:get_meta():set_string("description", description)
  return itemstack
end
