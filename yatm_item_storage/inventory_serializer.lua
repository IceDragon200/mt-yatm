local is_blank = assert(foundation.com.is_blank)

local InventorySerializer = {}

function InventorySerializer.description(dumped_list)
  local count = dumped_list.size
  local used = 0
  for key,item_stack in pairs(dumped_list.data) do
    if not is_blank(item_stack.name) and item_stack.count > 0 then
      used = used + 1
    end
  end
  return used .. " / " .. count
end

function InventorySerializer.serialize_item_stack(item_stack)
  local item_name = item_stack:get_name()
  local count = item_stack:get_count()
  local wear = item_stack:get_wear()
  local meta = item_stack:get_meta():to_table()
  local inventory = {}

  if meta.inventory then
    for name,list in pairs(meta.inventory) do
      inventory[name] = InventorySerializer.serialize(list)
    end
  end

  meta.inventory = inventory

  return {
    name = item_name,
    count = count,
    wear = wear,
    meta = meta,
  }
end

function InventorySerializer.serialize(list)
  list = list or {}

  local result = {
    size = #list,
    data = {},
  }

  for key,item_stack in pairs(list) do
    result.data[key] = InventorySerializer.serialize_item_stack(item_stack)
  end
  return result
end

function InventorySerializer.deserialize_item_stack(source_stack)
  local item_stack = ItemStack({
    name = source_stack.name,
    count = source_stack.count,
    wear = source_stack.wear
  })
  local meta = item_stack:get_meta()

  local new_meta = {}
  for key,value in pairs(source_stack.meta) do
    if key == "inventory" then
      local inventory = {}
      for name,serialized_list in pairs(source_stack.meta.inventory) do
        inventory[name] = InventorySerializer.deserialize(serialized_list, {})
      end
      new_meta[key] = inventory
    else
      new_meta[key] = value
    end
  end

  meta:from_table(new_meta)
  return item_stack
end

--
--
--
function InventorySerializer.deserialize_list(dumped, target_list)
  assert(dumped, "expected dumped inventory list")
  assert(target_list, "expected a target inventory list")
  for i = 1,dumped.size do
    local stack = dumped.data[i]
    local item_stack = target_list[i] or ItemStack({
      name = "",
      count = 0
    })
    target_list[i] = InventorySerializer.deserialize_item_stack(stack, item_stack)
  end

  return target_list
end

yatm_item_storage.InventorySerializer = InventorySerializer
