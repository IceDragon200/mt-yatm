-- @namespace yatm.icbm
local Groups = assert(foundation.com.Groups)

yatm.icbm = yatm.icbm or {}

-- @spec is_item_icbm_warhead(ItemDefinition): Boolean
function yatm.icbm.is_item_icbm_warhead(item)
  return Groups.has_group(item, "icbm_warhead")
end

-- @spec is_item_stack_icbm_warhead(ItemStack): Boolean
function yatm.icbm.is_item_stack_icbm_warhead(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return yatm.icbm.is_item_icbm_warhead(def)
    end
  end
  return false
end

-- @spec is_item_icbm_shell(ItemDefinition): Boolean
function yatm.icbm.is_item_icbm_shell(item)
  return Groups.has_group(item, "icbm_shell")
end

-- @spec is_item_stack_icbm_shell(ItemStack): Boolean
function yatm.icbm.is_item_stack_icbm_shell(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return yatm.icbm.is_item_icbm_shell(def)
    end
  end
  return false
end
