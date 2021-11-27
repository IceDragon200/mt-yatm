local Groups = assert(foundation.com.Groups)
local InventorySerializer = assert(yatm.items.InventorySerializer)

-- @namespace yatm.dscs
yatm.dscs = yatm.dscs or {}

-- @spec get_drive_capacity(ItemStack): Integer
function yatm.dscs.get_drive_capacity(item_stack)
  return item_stack:get_definition().drive_capacity
end

--
-- Only Ele and Fluid drives
-- This denotes the stack size of each cell.
--
function yatm.dscs.get_drive_stack_size(item_stack)
  return item_stack:get_definition().drive_stack_size
end

-- @spec set_drive_label(ItemStack, drive_label: String): ItemStack
function yatm.dscs.set_drive_label(item_stack, drive_label)
  local meta = item_stack:get_meta()
  meta:set_string("drive_label", drive_label)
  if drive_label ~= "" then
    meta:set_string("description", item_stack:get_definition().description .. " [" .. drive_label .. "]")
  else
    meta:set_string("description", "")
  end
  return item_stack
end

-- @spec get_drive_label(ItemStack): String
function yatm.dscs.get_drive_label(item_stack)
  local meta = item_stack:get_meta()
  return meta:get_string("drive_label")
end

function yatm.dscs.load_fluid_inventory_from_drive(fluid_inventory_name, item_stack)
  local inv = yatm.fluids.fluid_inventories:create_fluid_inventory(fluid_inventory_name)
  local meta = item_stack:get_meta()

  local capacity = yatm.dscs.get_drive_capacity(item_stack)
  local stack_size = yatm.dscs.get_drive_stack_size(item_stack)

  local blob = meta:get_string("fluid_drive_contents")

  if blob and #blob > 0 then
    inv:deserialize(blob)
  end

  -- reset the size afterwards
  inv:set_size("main", capacity)
  inv:set_max_stack_size("main", stack_size)

  return inv
end

function yatm.dscs.overload_fluid_inventory_from_drive(fluid_inventory_name, item_stack)
  local inv = yatm.fluids.fluid_inventories:get_fluid_inventory(fluid_inventory_name)

  if inv then
    minetest.log("warning", "fluid inventory name=" .. fluid_inventory_name .. " still exists")
    return inv
  end
  return yatm.dscs.load_fluid_inventory_from_drive(fluid_inventory_name, item_stack)
end

function yatm.dscs.persist_inventory_list_to_drive(item_stack, list)
  if yatm.dscs.is_item_stack_item_drive(item_stack) then
    local list_dump = InventorySerializer.dump_list(list)
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
    list = InventorySerializer.load_list(drive_contents, list)
  end
  return list, capacity
end

function yatm.dscs.is_item_stack_inventory_drive(item_stack)
  return Groups.has_group(item_stack:get_definition(), "inventory_drive")
end

function yatm.dscs.is_item_stack_ele_drive(item_stack)
  return Groups.has_group(item_stack:get_definition(), "ele_drive")
end

function yatm.dscs.is_item_stack_fluid_drive(item_stack)
  return Groups.has_group(item_stack:get_definition(), "fluid_drive")
end

function yatm.dscs.is_item_stack_item_drive(item_stack)
  return Groups.has_group(item_stack:get_definition(), "item_drive")
end
