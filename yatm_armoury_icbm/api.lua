yatm.icbm = yatm.icbm or {}

function yatm.icbm.is_item_icbm_warhead(item_stack)
  return yatm_core.groups.has_group(item, "icbm_warhead")
end

function yatm.icbm.is_item_stack_icbm_warhead(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return yatm.icbm.is_item_icbm_warhead(def)
    end
  end
  return false
end

function yatm.icbm.is_item_icbm_shell(item)
  return yatm_core.groups.has_group(item, "icbm_shell")
end

function yatm.icbm.is_item_stack_icbm_shell(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return yatm.icbm.is_item_icbm_shell(def)
    end
  end
  return false
end
