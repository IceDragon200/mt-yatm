function yatm_core.inspect_itemstack(stack)
  if stack then
    return "stack[" .. stack:get_name() .. "/" .. stack:get_count() .. "]"
  else
    return "nil"
  end
end

function yatm_core.itemstack_is_blank(stack)
  if stack then
    return yatm_core.is_blank(stack:get_name()) or stack:get_count() == 0
  else
    return true
  end
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
    local itemdef = minetest.registered_items[itemstack:get_name()]
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
