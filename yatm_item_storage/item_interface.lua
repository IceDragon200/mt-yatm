local InventoryList = assert(foundation.com.InventoryList)
local ItemInterface = {
  version = "1.1.0"
}

local function default_allow_replace_item(self, pos, dir, item_stack)
  return false
end

local function default_allow_insert_item(self, pos, dir, item_stack)
  return true
end

local function default_allow_extract_item(self, pos, dir, item_stack)
  return true
end

local function default_get_item(self, pos, dir)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local list = inv:get_list(self.inventory_name)
  if list then
    return InventoryList.first_present_stack(list)
  else
    print("ERROR", minetest.pos_to_string(pos), "inventory does not exist", self.inventory_name)
    return nil, "inventory not found"
  end
end

local function default_replace_item(self, pos, dir, item_stack, commit)
  if self:allow_replace_item(pos, dir, item_stack) then
    -- replace is not implemented by default
  end
  return nil, "not implemented"
end

local function default_room_for_item(self, pos, dir, item_stack)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  return inv:room_for_item(self.inventory_name, item_stack)
end

local function default_insert_item(self, pos, dir, item_stack, commit)
  if self:allow_insert_item(pos, dir, item_stack) then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if commit then
      local remaining = inv:add_item(self.inventory_name, item_stack)
      self:on_insert_item(pos, dir, item_stack)
      return remaining
    else
      local list = inv:get_list(self.inventory_name)
      local _new_list, remaining = InventoryList.merge_stack(list, item_stack)
      return remaining
    end
  end
  return nil, "insert not allowed"
end

local function default_on_insert_item(self, pos, dir, item_stack)
  -- nothing
end

local function default_on_extract_item(self, pos, dir, item_stack_or_count)
  -- nothing
end

local function default_extract_item(self, pos, dir, item_stack_or_count, commit)
  if self:allow_extract_item(pos, dir, item_stack_or_count) then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local list = inv:get_list(self.inventory_name)
    if list then
      local new_list, extracted = InventoryList.extract_stack(list, item_stack_or_count)
      if commit then
        inv:set_list(self.inventory_name, new_list)
        self:on_extract_item(pos, dir, item_stack_or_count)
      end
      return extracted
    else
      return nil, "list not available"
    end
  end
  return nil, "extract not allowed"
end

local function directional_get_item(self, pos, dir)
  local inventory_name = self:dir_to_inventory_name(pos, dir)
  if inventory_name then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local list = inv:get_list(inventory_name)
    if list then
      return InventoryList.first_present_stack(list)
    else
      print("ERROR", minetest.pos_to_string(pos), "inventory does not exist", inventory_name)
      return nil, "inventory not found"
    end
  end
  return nil, "no inventory"
end

local function directional_replace_item(self, pos, dir, item_stack, commit)
  if self:allow_replace_item(pos, dir, item_stack) then
    -- replace is not implemented by default
  end
  return nil, "not implemented"
end

local function directional_room_for_item(self, pos, dir, item_stack)
  local inventory_name = self:dir_to_inventory_name(pos, dir)
  if inventory_name then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    return inv:room_for_item(inventory_name, item_stack)
  end
  return nil, "no inventory"
end

local function directional_insert_item(self, pos, dir, item_stack, commit)
  if self:allow_insert_item(pos, dir, item_stack) then
    local inventory_name = self:dir_to_inventory_name(pos, dir)
    if inventory_name then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      if commit then
        local remaining = inv:add_item(inventory_name, item_stack)
        self:on_insert_item(pos, dir, item_stack)
        return remaining
      else
        local list = inv:get_list(inventory_name)
        local _new_list, remaining = InventoryList.merge_stack(list, item_stack)
        return remaining
      end
    else
      return nil, "no inventory"
    end
  end
  return nil, "insert not allowed"
end

local function directional_extract_item(self, pos, dir, item_stack_or_count, commit)
  if self:allow_extract_item(pos, dir, item_stack_or_count) then
    local inventory_name = self:dir_to_inventory_name(pos, dir)
    if inventory_name then
      local meta = minetest.get_meta(pos)
      local inv = meta:get_inventory()
      local list = inv:get_list(inventory_name)
      local new_list, extracted = InventoryList.extract_stack(list, item_stack_or_count)
      if commit then
        inv:set_list(inventory_name, new_list)
        self:on_extract_item(pos, dir, item_stack_or_count)
      end
      return extracted
    else
      return nil, "no inventory"
    end
  end
  return nil, "extract not allowed"
end

function ItemInterface.new()
  local item_interface = {
    allow_replace_item = default_allow_replace_item,
    allow_insert_item = default_allow_insert_item,
    allow_extract_item = default_allow_extract_item,

    on_insert_item = default_on_insert_item,
    on_extract_item = default_on_extract_item,
  }

  return item_interface
end

function ItemInterface.new_simple(inventory_name)
  local item_interface = ItemInterface.new()

  item_interface.inventory_name = inventory_name

  item_interface.get_item = default_get_item
  item_interface.replace_item = default_replace_item
  item_interface.room_for_item = default_room_for_item
  item_interface.insert_item = default_insert_item
  item_interface.extract_item = default_extract_item

  return item_interface
end

function ItemInterface.new_directional(dir_to_inventory_name)
  local item_interface = ItemInterface.new()

  item_interface.dir_to_inventory_name = dir_to_inventory_name

  item_interface.get_item = directional_get_item
  item_interface.replace_item = directional_replace_item
  item_interface.room_for_item = directional_room_for_item
  item_interface.insert_item = directional_insert_item
  item_interface.extract_item = directional_extract_item

  return item_interface
end

yatm_item_storage.ItemInterface = ItemInterface
