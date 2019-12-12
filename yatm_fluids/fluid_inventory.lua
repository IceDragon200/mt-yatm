--
-- Utility module for creating and managing Fluid inventories
-- That is a list of fluids in a inventory like arrangement,
-- think item-based inventories but for fluids.
--
local FluidStack = yatm_fluids.FluidStack

local FluidInventory = yatm_core.Class:extends("FluidInventory")
local ic = FluidInventory.instance_class

function ic:initialize(name, size, max_capacity)
  self.name = name
  self.size = size
  self.max_capacity = max_capacity
  self.entries = {}

  local inventory = self.m_inventories[name]

  for i = 1,size do
    inventory.entries[i] = FluidStack.new_empty()
  end
end

function ic:is_empty()
  for _, slot_stack in pairs(self.entries) do
    if not FluidStack.is_empty(slot_stack) then
      return false
    end
  end
  return true
end

function ic:get_fluid_stack(index)
  return self.entries[index]
end

function ic:set_fluid_stack(index, fluid_stack)
  if fluid_stack then
    self.entries[index] = FluidStack.copy(fluid_stack)
    if self.max_capacity > 0 then
      self.entries[index].amount = math.min(self.entries[index].amount, self.max_capacity)
    end
  else
    self.entries[index] = FluidStack.new_empty()
  end
  return self
end

function ic:contains_fluid_stack(fluid_stack)
  -- TODO: should this support 'amount' rollover?
  --       that is, if the given fluid stack has an amount that exceeds the max_capacity
  --       should it look for other slots until that amount is 0?
  for _, slot_stack in pairs(self.entries) do
    if FluidStack.same_fluid(slot_stack, fluid_stack) then
      return slot_stack.amount >= fluid_stack.amount
    end
  end
  return false
end

function ic:add_fluid_stack(fluid_stack)
  assert(fluid_stack, "expected a fluid stack")

  local remaining_stack = FluidStack.copy(fluid_stack)

  for i = 1,self.size do
    if remaining_stack.amount <= 0 then
      break
    end
    local slot_stack = self.entries[i]
    if FluidStack.is_empty(slot_stack) then
      self.entries[i] = FluidStack.merge({}, remaining_stack)
    elseif FluidStack.same_fluid(slot_stack, remaining_stack) then
      local new_stack = FluidStack.merge(slot_stack, remaining_stack)
      if self.max_capacity > 0 then
        local new_amount = math.min(new_stack.amount, self.max_capacity)
        local used_amount = new_amount - slot_stack.amount
        remaining_stack.amount = remaining_stack.amount - used_amount
      end
      self.entries[i] = new_stack
    end
  end
  return self
end

--
--
--
local FluidInventoryRegistry = yatm_core.Class:extends("FluidInventoryRegistry")
local ic = FluidInventoryRegistry.instance_class

function ic:initialize()
  self.m_inventories = {}
end

--
--
-- :create_fluid_inventory(string, integer, integer)
--   Name is a `mod_name:inventory_name` string that identifies the inventory
--   size is how many slots are available in the inventory
--   max_capacity - is how much fluid can be stored in any one cell
--                  unlike items that have a stack_size, fluids do not enforce a limit.
--                  A max capacity of `0` will uncap the limit
function ic:create_fluid_inventory(name, size, max_capacity)
  assert(name, "expected a name")
  assert(size, "expected a size")
  assert(max_capacity, "expected a max capacity")
  if self.m_inventories[name] then
    error("fluid inventory `" .. name .. "` already exists")
  end
  self.m_inventories[name] = FluidInventory:new(name, size, max_capacity)
end

function ic:get_fluid_inventory(name)
  return self.m_inventories[name]
end

function ic:destroy_fluid_inventory(name)
  self.m_inventories[name] = nil
  return self
end

yatm_fluids.FluidInventory = FluidInventory
yatm_fluids.FluidInventoryRegistry = FluidInventoryRegistry
