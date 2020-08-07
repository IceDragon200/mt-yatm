--
-- Utility module for creating and managing Fluid inventories
-- That is a list of fluids in a inventory like arrangement,
-- think item-based inventories but for fluids.
--
local FluidStack = yatm_fluids.FluidStack

local FluidInventory = foundation.com.Class:extends("FluidInventory")
local ic = FluidInventory.instance_class

function ic:initialize(name)
  self.name = name
  self.m_lists = {}
end

function ic:set_size(list_name, size)
  if size > 0 then
    local old_list = self.m_lists[list_name]
    self.m_lists[list_name] = {
      size = size,
      max_stack_size = 0,
      entries = {}
    }

    local list = self.m_lists[list_name]

    if old_list then
      list.max_stack_size = old_list.max_stack_size
      for i = 1,list.size do
        list.entries[i] = old_list.entries[i] or FluidStack.new_empty()
      end
    else
      for i = 1,list.size do
        list.entries[i] = FluidStack.new_empty()
      end
    end
  end
  return self
end

function ic:set_max_stack_size(list_name, max_stack_size)
  local list = self.m_lists[list_name]
  if list then
    list.max_stack_size = max_stack_size
  end
  return self
end

function ic:is_empty(list_name)
  local list = self.m_lists[list_name]
  if list then
    for _, slot_stack in pairs(list.entries) do
      if not FluidStack.is_empty(slot_stack) then
        return false
      end
    end
  end
  return true
end

function ic:get_fluid_stack(list_name, index)
  local list = self.m_lists[list_name]
  if list then
    return list.entries[index]
  else
    return nil
  end
end

function ic:set_fluid_stack(list_name, index, fluid_stack)
  local list = self.m_lists[list_name]
  if list then
    if fluid_stack then
      list.entries[index] = FluidStack.copy(fluid_stack)
      if list.max_stack_size > 0 then
        list.entries[index].amount = math.min(list.entries[index].amount, list.max_stack_size)
      end
    else
      list.entries[index] = FluidStack.new_empty()
    end
  end
  return self
end

function ic:contains_fluid_stack(list_name, fluid_stack)
  -- TODO: should this support 'amount' rollover?
  --       that is, if the given fluid stack has an amount that exceeds the max_stack_size
  --       should it look for other slots until that amount is 0?
  local list = self.m_lists[list_name]
  if list then
    for _, slot_stack in pairs(list.entries) do
      if FluidStack.same_fluid(slot_stack, fluid_stack) then
        return slot_stack.amount >= fluid_stack.amount
      end
    end
  end
  return false
end

function ic:add_fluid_stack(list_name, fluid_stack)
  assert(fluid_stack, "expected a fluid stack")

  local list = self.m_lists[list_name]
  if list then
    local remaining_stack = FluidStack.copy(fluid_stack)

    for i = 1,list.size do
      if remaining_stack.amount <= 0 then
        break
      end
      local slot_stack = list.entries[i]
      local new_stack
      if FluidStack.is_empty(slot_stack) then
        new_stack = FluidStack.copy(remaining_stack)
      elseif FluidStack.same_fluid(slot_stack, remaining_stack) then
        new_stack = FluidStack.merge(slot_stack, remaining_stack)
      end

      if new_stack then
        if list.max_stack_size > 0 then
          local new_amount = math.min(new_stack.amount, list.max_stack_size)
          local used_amount = new_amount - slot_stack.amount
          remaining_stack.amount = remaining_stack.amount - used_amount
          new_stack.amount = new_amount
        end
        list.entries[i] = new_stack
      end
    end
  end
  return self
end

function ic:to_table()
  return {
    name = self.name,
    lists = self.m_lists,
  }
end

function ic:from_table(data_dump)
  self.name = data_dump.name
  self.m_lists = data_dump.lists
  return self
end

function ic:deserialize(blob)
  local dumped_data = minetest.deserialize(blob)
  return self:from_table(dumped_data)
end

function ic:serialize()
  return minetest.serialize(self:to_table())
end

function ic:deserialize_list(list_name, blob)
  local dumped_data = minetest.deserialize(blob)
  self.m_lists[list_name] = dumped_data
  return self
end

function ic:serialize_list(list_name)
  local list = assert(self.m_lists[list_name], "expected list to exist")
  return minetest.serialize(list)
end

--
--
--
local FluidInventoryRegistry = foundation.com.Class:extends("FluidInventoryRegistry")
local ic = FluidInventoryRegistry.instance_class

function ic:initialize()
  self.m_inventories = {}
end

--
--
-- :create_fluid_inventory(string)
--   Name is a `mod_name:inventory_name` string that identifies the inventory
function ic:create_fluid_inventory(name)
  assert(name, "expected a name")
  if self.m_inventories[name] then
    error("fluid inventory `" .. name .. "` already exists")
  end
  print("Creating Fluid Inventory name=" .. name)
  self.m_inventories[name] = FluidInventory:new(name)
  return self.m_inventories[name]
end

function ic:get_fluid_inventory(name)
  return self.m_inventories[name]
end

function ic:destroy_fluid_inventory(name)
  print("Destroyed Fluid Inventory name=" .. name)
  self.m_inventories[name] = nil
  return self
end

function ic:fluid_inventory_to_table(name)
  local inventory = self.m_inventories[name]
  if inventory then
    return inventory:dump()
  end
  return nil
end

function ic:fluid_inventory_from_table(name, data_dump)
  local inventory = self.m_inventories[name]
  if inventory then
    return inventory:load(data_dump)
  end
  return nil
end

yatm_fluids.FluidInventory = FluidInventory
yatm_fluids.FluidInventoryRegistry = FluidInventoryRegistry
