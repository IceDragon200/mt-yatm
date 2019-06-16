--
-- Determines if the given stack is a form of ammunition
--
-- @spec yatm_armoury.is_stack_ammunition(ItemStack.t) :: boolean
function yatm_armoury.is_stack_ammunition(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      if def.groups.ammunition then
        return def.groups.ammunition > 0
      end
    end
  end
  return false
end
