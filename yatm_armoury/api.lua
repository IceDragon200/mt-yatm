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

function yatm_armoury.is_same_calibre_item_stacks(a, b)
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
  if yatm_armoury.is_same_calibre_item_stacks(magazine_stack, bullet_stack) then
    if not yatm_armoury.is_magazine_full(magazine_stack) then
      local bullet_itemdef = bullet_stack:get_definition()
      local magazine_itemdef = magazine_stack:get_definition()

      local magazine_meta = magazine_stack:get_meta()

      -- these are how many bullets are currently in the magazine
      local bullet_count = magazine_meta:get_int("bullet_count")
      -- this is a string representing the bullet order
      local bullet_string = magazine_meta:get_string("bullet_string")
      -- this is the maximum size allowed for the magazine
      local magazine_size = magazine_itemdef.magazine_size

      local remaining_space = magazine_size - bullet_count
      if remaining_space > 0 then
        local bullets_to_take = math.min(bullet_stack:get_count(), remaining_space)

        if bullets_to_take > 0 then
          bullet_stack:take_item(bullets_to_take)

          for i = 1,bullets_to_take do
            -- the ammo_code is a single char that will be placed into the bullet_string
            -- notice it's prefixed to the string, this because all magazines are LIFO
            bullet_string = bullet_itemdef.ammo_code .. bullet_string
          end
          magazine_meta:set_int("bullet_count", bullet_count + bullets_to_take)
          magazine_meta:set_string("bullet_string", bullet_string)
        end
      end
    end
  end
  return bullet_stack, magazine_stack
end
