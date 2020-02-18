yatm.computers = yatm_oku.computers

function yatm_oku.get_floppy_disk_size(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return def.floppy_disk.size
    end
  end
  return 0
end

function yatm_oku.is_stack_floppy_disk(item_stack)
  if item_stack then
    local def = item_stack:get_definition()
    if def then
      return yatm_core.groups.has_group(def, "floppy_disk")
    end
  end
  return false
end
