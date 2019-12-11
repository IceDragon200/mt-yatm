yatm.dscs = yatm.dscs or {}

function yatm.dscs.set_drive_label(item_stack, drive_label)
  local meta = item_stack:get_meta()
  meta:set_string("drive_label", drive_label)
  if drive_label ~= "" then
    meta:set_string("description", item_stack:get_definition().description .. " [" .. drive_label .. "]")
  else
    meta:set_string("description", "")
  end
end

function yatm.dscs.persist_inventory_list_to_drive(item_stack, list)
  if yatm.dscs.is_item_stack_item_drive(item_stack) then
    local list_dump = yatm_item_storage.InventorySerializer.serialize(list)
    local stack_meta = item_stack:get_meta()
    stack_meta:set_string("drive_contents", minetest.serialize(list_dump))

    return item_stack
  end
  return nil
end

function yatm.dscs.load_inventory_list_from_drive(item_stack)
  local stack_meta = item_stack:get_meta()
  local drive_contents_dump = stack_meta:get_string("drive_contents")
  local drive_contents = minetest.deserialize(drive_contents_dump)
  local capacity = assert(item_stack:get_definition().drive_capacity, "expected drive to have a capacity")
  local list = {}
  if drive_contents then
    list = yatm_item_storage.InventorySerializer.deserialize_list(drive_contents, list)
  end
  return list, capacity
end

function yatm.dscs.is_item_stack_inventory_drive(item_stack)
  return yatm_core.groups.has_group(item_stack:get_definition(), "inventory_drive")
end

function yatm.dscs.is_item_stack_ele_drive(item_stack)
  return yatm_core.groups.has_group(item_stack:get_definition(), "ele_drive")
end

function yatm.dscs.is_item_stack_fluid_drive(item_stack)
  return yatm_core.groups.has_group(item_stack:get_definition(), "fluid_drive")
end

function yatm.dscs.is_item_stack_item_drive(item_stack)
  return yatm_core.groups.has_group(item_stack:get_definition(), "item_drive")
end
