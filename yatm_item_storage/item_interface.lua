local InventoryList = assert(yatm_core.InventoryList)
local ItemInterface = {}

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
  return InventoryList.first_stack(list)
end

local function default_replace_item(self, pos, dir, item_stack, commit)
  if self.allow_replace_item(pos, dir, item_stack) then
    -- replace is not implemented by default
  end
  return nil
end

local function default_insert_item(self, pos, dir, item_stack, commit)
  if self.allow_insert_item(pos, dir, item_stack) then
    local inv = meta:get_inventory()
    local list = inv:get_list(self.inventory_name)
    local new_list, remaining = InventoryList.merge_stack(list, item_stack)
    if commit then
      inv:set_list(self.inventory_name, new_list)
    end
    return remaining
  end
  return nil
end

local function default_extract_item(self, pos, dir, item_stack_or_count, commit)
  if self.allow_extract_item(pos, dir, item_stack_or_count) then
    local inv = meta:get_inventory()
    local list = inv:get_list(self.inventory_name)
    local new_list, extracted = InventoryList.extract_stack(list, item_stack_or_count)
    if commit then
      inv:set_list(self.inventory_name, new_list)
    end
    return extracted
  end
  return nil
end

local function directional_get_item(self, pos, dir)
  local inventory_name = self:dir_to_inventory_name(pos, dir)
  if inventory_name then
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local list = inv:get_list(inventory_name)
    return InventoryList.first_stack(list)
  end
  return nil
end

local function directional_replace_item(self, pos, dir, item_stack, commit)
  if self.allow_replace_item(pos, dir, item_stack) then
    -- replace is not implemented by default
  end
  return nil
end

local function directional_insert_item(self, pos, dir, item_stack, commit)
  if self.allow_insert_item(pos, dir, item_stack) then
    local inventory_name = self:dir_to_inventory_name(pos, dir)
    if inventory_name then
      local inv = meta:get_inventory()
      local list = inv:get_list(inventory_name)
      local new_list, remaining = InventoryList.merge_stack(list, item_stack)
      if commit then
        inv:set_list(self.inventory_name, new_list)
      end
      return remaining
    end
  end
  return nil
end

local function directional_extract_item(self, pos, dir, item_stack_or_count, commit)
  if self.allow_extract_item(pos, dir, item_stack_or_count) then
    local inventory_name = self:dir_to_inventory_name(pos, dir)
    if inventory_name then
      local inv = meta:get_inventory()
      local list = inv:get_list(inventory_name)
      local new_list, extracted = InventoryList.extract_stack(list, item_stack_or_count)
      if commit then
        inv:set_list(self.inventory_name, new_list)
      end
      return extracted
    end
  end
  return nil
end

function ItemInterface.new()
  local item_interface = {
    allow_replace_item = default_allow_replace_item,
    allow_insert_item = default_allow_insert_item,
    allow_extract_item = default_allow_extract_item,
  }

  return item_interface
end

function ItemInterface.new_simple(inventory_name)
  local item_interface = ItemInterface.new()
  item_interface.inventory_name = inventory_name
  item_interface.get_item = default_get_item
  item_interface.replace_item = default_replace_item
  item_interface.insert_item = default_insert_item
  item_interface.extract_item = default_extract_item

  return item_interface
end

function ItemInterface.new_directional(dir_to_inventory_name)
  local item_interface = ItemInterface.new()
  item_interface.dir_to_inventory_name = dir_to_inventory_name
  item_interface.get_item = directional_get_item
  item_interface.replace_item = directional_replace_item
  item_interface.insert_item = directional_insert_item
  item_interface.extract_item = directional_extract_item

  return item_interface
end

yatm_item_storage.ItemInterface = ItemInterface
