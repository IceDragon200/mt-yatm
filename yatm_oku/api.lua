local path_join = assert(foundation.com.path_join)
local Groups = assert(foundation.com.Groups)
local Computers = assert(yatm_oku.Computers)

--- @namespace yatm_oku
--- @const computers: Computers
yatm_oku.computers = Computers:new({
  root_dir = path_join(core.get_worldpath(), "/yatm/oku")
})

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

--- @namespace yatm
--- @const computers: Computers
yatm.computers = assert(yatm_oku.computers)
