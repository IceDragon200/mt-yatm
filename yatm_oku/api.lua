--- @namespace yatm_oku

local Groups = assert(foundation.com.Groups)

yatm.computers = assert(yatm_oku.computers)

--- @spec get_floppy_disk_size(ItemStack): Integer
function yatm_oku.get_floppy_disk_size(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return def.floppy_disk.size
    end
  end
  return 0
end

--- @spec is_stack_floppy_disk(ItemStack): Boolean
function yatm_oku.is_stack_floppy_disk(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return Groups.has_group(def, "floppy_disk")
    end
  end
  return false
end
