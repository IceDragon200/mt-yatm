--
-- Simple utility module for dealing with stacks of fluids
--
local fluid_registry = assert(yatm_fluids.fluid_registry)
local FluidUtils = assert(yatm_fluids.Utils)

--- @namespace yatm_fluids

--- @class FluidStack
local FluidStack = {
  metatable = {
    __index = {},
  },
}

do
  --- @since "2.6.0"
  --- @spec is_fluid_stack(obj: Any): Boolean
  function FluidStack.is_fluid_stack(obj)
    return getmetatable(obj) == FluidStack.metatable
  end

  --- @since "2.6.0"
  --- @spec alloc(): FluidStack
  function FluidStack.alloc()
    return setmetatable({ name = "", amount = 0 }, FluidStack.metatable)
  end

  --- @spec new(name: String, amount: Integer): FluidStack
  function FluidStack.new(name, amount)
    return setmetatable({ name = name, amount = amount or 0 }, FluidStack.metatable)
  end

  --- @spec new_empty(): FluidStack
  function FluidStack.new_empty()
    return FluidStack.new(nil, 0)
  end

  --- @spec new_group(group_name: String, amount: Integer): FluidStack
  function FluidStack.new_group(group_name, amount)
    return FluidStack.new("group:" .. group_name, amount)
  end

  --- @spec new_wildcard(amount: Integer): FluidStack
  function FluidStack.new_wildcard(amount)
    return FluidStack.new("*", amount)
  end

  --- @spec copy(fluid_stack: FluidStack): FluidStack
  function FluidStack.copy(fluid_stack)
    return FluidStack.new(fluid_stack.name, fluid_stack.amount)
  end

  --- @spec same_fluid(a?: FluidStack, b?: FluidStack): Boolean
  function FluidStack.is_same_fluid(a, b)
    if a and b then
      return FluidUtils.matches(a.name, b.name)
    end

    return false
  end

  --- @spec is_same_fluid_or_replacable_by(FluidStack, FluidStack): Boolean
  function FluidStack.is_same_fluid_or_replacable_by(base, replacement)
    if not base then
      return replacement ~= nil
    end
    return FluidStack.is_same_fluid(base, replacement)
  end

  --- @spec equals(FluidStack, FluidStack): Boolean
  function FluidStack.equals(a, b)
    if a and b then
      if FluidUtils.matches(a.name, b.name) then
        return a.amount == b.amount
      end
    end

    return false
  end

  --- @spec get_fluid(FluidStack): Fluid
  function FluidStack.get_fluid(fluid_stack)
    if fluid_stack and fluid_stack.name then
      return fluid_registry.get_fluid(fluid_stack.name)
    end
    return nil
  end

  --- @spec is_member_of_group(FluidStack, group_name: String): Boolean
  function FluidStack.is_member_of_group(fluid_stack, group_name)
    if fluid_stack then
      if fluid_stack.name == "*" then
        return true
      elseif fluid_stack.name == ("group:" .. group_name) then
        return true
      else
        local fluid = FluidStack.get_fluid(fluid_stack)
        if fluid and fluid.groups[group_name] then
          return true
        end
      end
    end
    return false
  end

  --- @spec to_string(FluidStack, capacity?: Integer): String
  function FluidStack.to_string(fluid_stack, capacity)
    local result = "Empty"
    if fluid_stack and fluid_stack.amount > 0 then
      result = fluid_stack.name .. "(" .. tostring(fluid_stack.amount)
      if capacity then
        result = result .. " / " .. tostring(capacity)
      end
      result = result .. ")"
    end
    return result
  end

  --- @spec pretty_format(FluidStack, capacity?: Integer): String
  function FluidStack.pretty_format(fluid_stack, capacity)
    local name = ""
    local amount = 0
    if fluid_stack then
      local fluiddef = fluid_registry.get_fluid(fluid_stack.name)
      if fluiddef then
        name = fluiddef.description or fluid_stack.name
      else
        name = fluid_stack.name
      end
      amount = fluid_stack.amount
    end
    if capacity then
      return "<"..name..">".." ("..amount.." / "..capacity..")"
    else
      return "<"..name..">".." ("..amount..")"
    end
  end

  function FluidStack.set_name(fluid_stack, name)
    return FluidStack.new(name, fluid_stack.amount)
  end

  function FluidStack.set_amount(fluid_stack, new_amount)
    return FluidStack.new(fluid_stack.name, new_amount)
  end

  function FluidStack.inc_amount(fluid_stack, amount)
    return FluidStack.set_amount(fluid_stack, math.max(0, fluid_stack.amount + amount))
  end

  function FluidStack.dec_amount(fluid_stack, amount)
    return FluidStack.set_amount(fluid_stack, math.max(0, fluid_stack.amount - amount))
  end

  --- Merges any varidic number of fluid stacks into the resulting fluid stack
  --- @since "2.6.0"
  --- @mutative result
  --- @spec merge(result: FluidStack, ...FluidStack): FluidStack
  function FluidStack.merge(result, ...)
    assert(result, "expected a fluid stack")
    local len = select('#', ...)
    if len > 0 then
      local b
      local bname
      for i = 1,len do
        b = select(i, ...)
        bname = fluid_registry.normalize_fluid_name(b.name)
        if not result.name or bname == result.name then
          result.amount = result.amount + b.amount
        end
      end
    end
    return result
  end

  --- @since "2.6.0"
  --- @spec merge_new(FluidStack, ...FluidStack): FluidStack
  function FluidStack.merge_new(a, ...)
    assert(a, "expected a fluid stack")
    local result = FluidStack.new(
      fluid_registry.normalize_fluid_name(a.name),
      a.amount or 0
    )
    return FluidStack.merge(result, ...)
  end

  --- @mutative result
  --- @spec add(result: FluidStack, ...FluidStack): FluidStack
  FluidStack.add = FluidStack.merge

  --- @mutative result
  --- @spec subtract(FluidStack, ...FluidStack): FluidStack
  function FluidStack.subtract(result, ...)
    assert(result, "expected a fluid stack")
    local len = select('#', ...)
    if len > 0 then
      local b
      local bname
      for i = 1,len do
        b = select(i, ...)
        bname = fluid_registry.normalize_fluid_name(b.name)
        if not result.name or bname == result.name then
          result.amount = math.max(result.amount - b.amount, 0)
        end
      end
    end
    return result
  end

  --- @spec normalize(FluidStack): FluidStack
  function FluidStack.normalize(stack)
    return FluidStack.new(
      fluid_registry.normalize_fluid_name(stack.name),
      stack.amount
    )
  end

  --- @spec presence(FluidStack): FluidStack | nil
  function FluidStack.presence(fluid_stack)
    if fluid_stack and fluid_stack.name and fluid_stack.amount > 0 then
      return fluid_stack
    end
    return nil
  end

  --- @spec is_empty(FluidStack): Boolean
  function FluidStack.is_empty(fluid_stack)
    if fluid_stack and fluid_stack.name and fluid_stack.amount > 0 then
      return false
    end
    return true
  end
end

do
  --- @since "2.6.0"
  --- @spec metatable.__tostring(a: FluidStack): String
  FluidStack.metatable.__tostring = assert(FluidStack.to_string)

  --- @since "2.6.0"
  --- @spec metatable.__eq(a: FluidStack, b: FluidStack): String
  FluidStack.metatable.__eq = assert(FluidStack.equals)

  --- @since "2.6.0"
  --- @spec metatable.__add(a: FluidStack, b: FluidStack): FluidStack
  function FluidStack.metatable.__add(a, b)
    return FluidStack.add(FluidStack.copy(a), b)
  end

  --- @since "2.6.0"
  --- @spec metatable.__sub(a: FluidStack, b: FluidStack): FluidStack
  function FluidStack.metatable.__sub(a, b)
    return FluidStack.subtract(FluidStack.copy(a), b)
  end

  local ic = FluidStack.metatable.__index

  --- @since "2.6.0"
  --- @spec #copy(): FluidStack
  ic.copy = assert(FluidStack.copy)

  --- @since "2.6.0"
  --- @spec #is_same_fluid(other: FluidStack): Boolean
  ic.is_same_fluid = assert(FluidStack.is_same_fluid)

  --- @since "2.6.0"
  --- @spec #is_same_fluid_or_replacable_by(other: FluidStack): Boolean
  ic.is_same_fluid_or_replacable_by = assert(FluidStack.is_same_fluid_or_replacable_by)

  --- @since "2.6.0"
  --- @spec #equals(other: FluidStack): Boolean
  ic.equals = assert(FluidStack.equals)

  --- @since "2.6.0"
  --- @spec #get_fluid(): Fluid
  ic.get_fluid = assert(FluidStack.get_fluid)

  --- @since "2.6.0"
  --- @spec #is_member_of_group(group_name: String): Boolean
  ic.is_member_of_group = assert(FluidStack.is_member_of_group)

  --- @since "2.6.0"
  --- @spec #to_string(capacity?: Integer): String
  ic.to_string = assert(FluidStack.to_string)

  --- @since "2.6.0"
  --- @spec #pretty_format(capacity?: Integer): String
  ic.pretty_format = assert(FluidStack.pretty_format)

  --- @since "2.6.0"
  --- @mutative self
  --- @spec #merge(...FluidStack[]): FluidStack
  ic.merge = assert(FluidStack.merge)

  --- @since "2.6.0"
  --- @spec #merge_new(...FluidStack[]): FluidStack
  ic.merge_new = assert(FluidStack.merge_new)

  --- @since "2.6.0"
  --- @mutative self
  --- @spec #add(...FluidStack[]): FluidStack
  ic.add = assert(FluidStack.add)

  --- @since "2.6.0"
  --- @mutative self
  --- @spec #subtract(...FluidStack[]): FluidStack
  ic.subtract = assert(FluidStack.subtract)

  --- @since "2.6.0"
  --- @spec #normalize(): FluidStack
  ic.normalize = assert(FluidStack.normalize)

  --- @since "2.6.0"
  --- @spec #presence(): FluidStack | nil
  ic.presence = assert(FluidStack.presence)

  --- @since "2.6.0"
  --- @spec #is_empty(): Boolean
  ic.is_empty = assert(FluidStack.is_empty)
end

yatm_fluids.FluidStack = FluidStack
