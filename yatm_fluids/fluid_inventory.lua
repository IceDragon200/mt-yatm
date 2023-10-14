--
-- Utility module for creating and managing Fluid inventories
-- That is a list of fluids in a inventory like arrangement,
-- think item-based inventories but for fluids.
--
local FluidStack = assert(yatm_fluids.FluidStack)
local ErrorCodes = assert(yatm_fluids.ErrorCodes)

--- @namespace yatm_fluids

--- @class FluidInventory
local FluidInventory = foundation.com.Class:extends("FluidInventory")
do
  local ic = FluidInventory.instance_class

  --- @spec #initialize(name: String): void
  function ic:initialize(name)
    --- @member name: String
    self.name = assert(name)

    --- @member m_lists: { [list_name: String]: Table }
    self.m_lists = {}
  end

  --- Changes (and possibly create) a list specified by `list_name` of `size`
  --- If size is 0 the list will be removed instead.
  ---
  --- @spec #set_size(list_name: String, size: Integer): (Boolean, yatm_fluids.ErrorCode)
  function ic:set_size(list_name, size)
    assert(list_name, "expected a list name")
    assert(size, "expected a size")

    if size > 0 then
      local old_list = self.m_lists[list_name]
      local list = {
        size = size,
        max_stack_size = -1,
        entries = {}
      }
      self.m_lists[list_name] = list

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
    else
      self.m_lists[list_name] = nil
    end

    return true, ErrorCodes.ERR_OK
  end

  --- Retrieve the size of an inventory list
  ---
  --- @spec #get_size(list_name: String): (Integer, yatm_fluids.ErrorCode)
  function ic:get_size(list_name)
    assert(list_name, "expected a list name")

    local list = self.m_lists[list_name]
    if list then
      return list.size, ErrorCodes.ERR_OK
    end

    return 0, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #set_max_stack_size(
  ---   list_name: String,
  ---   max_stack_size: Integer
  --- ): (Boolean, yatm_fluids.ErrorCode)
  function ic:set_max_stack_size(list_name, max_stack_size)
    local list = self.m_lists[list_name]
    if list then
      list.max_stack_size = max_stack_size
      return true, ErrorCodes.ERR_OK
    end
    return false, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #get_max_stack_size(
  ---   list_name: String
  --- ): (Integer, yatm_fluids.ErrorCode)
  function ic:get_max_stack_size(list_name)
    local list = self.m_lists[list_name]
    if list then
      return list.max_stack_size, ErrorCodes.ERR_OK
    end
    return 0, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #is_empty(list_name: String): (Boolean, yatm_fluids.ErrorCode)
  function ic:is_empty(list_name)
    local list = self.m_lists[list_name]
    if list then
      for _, slot_stack in pairs(list.entries) do
        if not FluidStack.is_empty(slot_stack) then
          return false, ErrorCodes.ERR_FLUID_IS_PRESENT
        end
      end
      return true, ErrorCodes.ERR_OK
    end
    return true, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #get_fluid_stack(
  ---   list_name: String,
  ---   index: Integer
  --- ): (FluidStack | nil, yatm_fluids.ErrorCode)
  function ic:get_fluid_stack(list_name, index)
    local list = self.m_lists[list_name]
    if list then
      if index >= 1 and index <= list.size then
        return list.entries[index], ErrorCodes.ERR_OK
      end
      return nil, ErrorCodes.ERR_OUT_OF_RANGE
    end
    return nil, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #set_fluid_stack(
  ---   list_name: String,
  ---   index: Integer,
  ---   fluid_stack: FluidStack
  --- ): (Boolean, yatm_fluids.ErrorCode)
  function ic:set_fluid_stack(list_name, index, fluid_stack)
    local list = self.m_lists[list_name]
    if list then
      if index >= 1 and index <= list.size then
        if fluid_stack then
          list.entries[index] = FluidStack.copy(fluid_stack)
          if list.max_stack_size >= 0 then
            list.entries[index].amount = math.min(list.entries[index].amount, list.max_stack_size)
          end
        else
          list.entries[index] = FluidStack.new_empty()
        end
        return true, ErrorCodes.ERR_OK
      end
      return false, ErrorCodes.ERR_OUT_OF_RANGE
    end
    return false, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #contains_fluid_stack(
  ---   list_name: String,
  ---   fluid_stack: FluidStack
  --- ): (Boolean, yatm_fluids.ErrorCode)
  function ic:contains_fluid_stack(list_name, fluid_stack)
    -- TODO: should this support 'amount' rollover?
    --       that is, if the given fluid stack has an amount that exceeds the max_stack_size
    --       should it look for other slots until that amount is 0?
    local list = self.m_lists[list_name]
    if list then
      for _, slot_stack in pairs(list.entries) do
        if FluidStack.same_fluid(slot_stack, fluid_stack) then
          return slot_stack.amount >= fluid_stack.amount, ErrorCodes.ERR_OK
        end
      end
      return false, ErrorCodes.ERR_OK
    end
    return false, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- Attempts to add the given fluid stack to the inventory.
  --- Returns the leftover fluid_stack (non-mutative), but, if the list is unavailable
  --- the given fluid_stack is returned instead as the leftover.
  ---
  --- @spec #add_fluid_stack(
  ---   list_name: String,
  ---   fluid_stack: FluidStack
  --- ): (leftover: FluidStack, yatm_fluids.ErrorCode)
  function ic:add_fluid_stack(list_name, fluid_stack)
    assert(fluid_stack, "expected a fluid stack")

    local list = self.m_lists[list_name]
    if list then
      local remaining_stack = FluidStack.copy(fluid_stack)

      local slot_stack
      local new_stack
      local new_amount
      local used_amount

      for i = 1,list.size do
        if remaining_stack.amount <= 0 then
          break
        end
        slot_stack = list.entries[i]
        new_stack = nil
        if FluidStack.is_empty(slot_stack) then
          new_stack = FluidStack.copy(remaining_stack)
        elseif FluidStack.same_fluid(slot_stack, remaining_stack) then
          new_stack = FluidStack.merge(slot_stack, remaining_stack)
        end

        if new_stack then
          if list.max_stack_size >= 0 then
            new_amount = math.min(new_stack.amount, list.max_stack_size)
            used_amount = new_amount - slot_stack.amount
            remaining_stack.amount = remaining_stack.amount - used_amount
            new_stack.amount = new_amount
          end
          list.entries[i] = new_stack
        end
      end

      return remaining_stack, ErrorCodes.ERR_OK
    end

    return fluid_stack, ErrorCodes.ERR_LIST_NOT_FOUND
  end

  --- @spec #to_table(): Table
  function ic:to_table()
    return {
      name = self.name,
      lists = self.m_lists,
    }
  end

  --- @spec #from_table(data_dump: Table): self
  function ic:from_table(data_dump)
    self.name = data_dump.name
    self.m_lists = data_dump.lists
    return self
  end

  --- @spec #deserialize(blob: String): self
  function ic:deserialize(blob)
    local dumped_data = minetest.deserialize(blob)
    return self:from_table(dumped_data)
  end

  --- @spec #serialize(): String
  function ic:serialize()
    return minetest.serialize(self:to_table())
  end

  --- @spec #deserialize_list(list_name: String, blob: String): self
  function ic:deserialize_list(list_name, blob)
    local dumped_data = minetest.deserialize(blob)
    self.m_lists[list_name] = dumped_data
    return self
  end

  --- @spec #serialize_list(list_name: String): String
  function ic:serialize_list(list_name)
    local list = assert(self.m_lists[list_name], "expected list to exist")
    return minetest.serialize(list)
  end
end

--
--
--- @class FluidInventoryRegistry
local FluidInventoryRegistry = foundation.com.Class:extends("FluidInventoryRegistry")
do
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

  --- @spec #get_fluid_inventory(name: String): FluidInventory | nil
  function ic:get_fluid_inventory(name)
    return self.m_inventories[name]
  end

  --- @spec #destroy_fluid_inventory(name: String): self
  function ic:destroy_fluid_inventory(name)
    if self.m_inventories[name] then
      print("Destroyed Fluid Inventory name=`" .. name .. "`")
      self.m_inventories[name] = nil
    else
      print("Fluid Inventory name=`" .. name .. "` was to be destroyed, but it does not exist")
    end
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
end

yatm_fluids.FluidInventory = FluidInventory
yatm_fluids.FluidInventoryRegistry = FluidInventoryRegistry
