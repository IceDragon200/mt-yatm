--
-- Determines if the given stack is a form of ammunition
function yatm_armoury.is_stack_ammunition(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      return def.groups.ammunition > 0
    end
  end
  return false
end
