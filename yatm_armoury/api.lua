--
-- Determines if the given stack is a form of ammunition
--
-- @spec yatm_armoury.is_stack_ammunition(ItemStack) :: boolean
function yatm_armoury.is_stack_ammunition(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      return yatm_core.groups.has_group(def, "ammunition")
    end
  end
  return false
end

--
-- Determines if the given stack is a form of magazine
--
-- @spec yatm_armoury.is_stack_magazine(ItemStack) :: boolean
function yatm_armoury.is_stack_magazine(stack)
  if stack then
    local def = stack:get_definition()
    if def then
      return yatm_core.groups.has_group(def, "magazine")
    end
  end
  return false
end

function yatm_armoury.is_same_calibre_items(a, b)
  local ad = a:get_definition()
  local bd = b:get_definition()

  return ad.calibre == bd.calibre
end

function yatm_armoury.is_magazine_empty(magazine_stack)
  local magazine_meta = magazine_stack:get_meta()
  return (magazine_meta:get_int("bullet_count") or 0) == 0
end

function yatm_armoury.is_magazine_full(magazine_stack)
  local magazine_itemdef = magazine_stack:get_definition()
  local magazine_meta = magazine_stack:get_meta()
  return (magazine_meta:get_int("bullet_count") or 0) >= magazine_itemdef.magazine_size
end

--
-- Places the given cartridge/bullet/ammunition into a magazine
--
-- @spec yatm_armoury.add_bullet_to_magazine(ItemStack, ItemStack) :: (leftover_bullets :: ItemStack, new_magazine :: ItemStack)
function yatm_armoury.add_bullet_to_magazine(bullet_stack, magazine_stack)
  if yatm_armoury.is_same_calibre_items(magazine_stack, bullet_stack) then
    if not yatm_armoury.is_magazine_full(magazine_stack) then
      local bullet_itemdef = bullet_stack:get_definition()
      local magazine_itemdef = magazine_stack:get_definition()

      local magazine_meta = magazine_stack:get_meta()

      local bullet_count = magazine_meta:get_int("bullet_count")
      local bullet_string = magazine_meta:get_string("bullet_string")
      local magazine_size = magazine_itemdef.magazine_size

      local remaining_space = magazine_size - bullet_count
      local bullets_to_take = math.min(bullet_stack:get_count(), remaining_space)

      bullet_stack:take_item(bullets_to_take)
    end
  end
  return bullet_stack, magazine_stack
end
