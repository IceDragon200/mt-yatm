--[[
Simple utility module for dealing with stacks of fluids
]]
local FluidRegistry = assert(yatm_fluids.FluidRegistry)
local FluidStack = {}

function FluidStack.new(name, amount)
  return { name = name, amount = amount or 0 }
end

function FluidStack.new_empty()
  return FluidStack.new(nil, 0)
end

function FluidStack.new_group(group_name, amount)
  return FluidStack.new("group:" .. group_name, amount)
end

function FluidStack.new_wildcard(amount)
  return FluidStack.new("*", amount)
end

function FluidStack.copy(fluid_stack)
  return { name = fluid_stack.name, amount = fluid_stack.amount }
end

function FluidStack.get_fluid(fluid_stack)
  if fluid_stack and fluid_stack.name then
    return FluidRegistry.get_fluid(fluid_stack.name)
  end
  return nil
end

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

--[[
@spec FluidStack.pretty_format(FluidStack.t, capacity :: non_neg_integer | nil) :: String.t
]]
function FluidStack.pretty_format(fluid_stack, capacity)
  local name = ""
  local amount = 0
  if fluid_stack then
    local fluiddef = FluidRegistry.get_fluid(fluid_stack.name)
    if fluiddef then
      name = fluiddef.description or fluid_stack.name
    else
      name = fluid_stack.name
    end
    amount = fluid_stack.amount
  end
  if capacity then
    return "<" .. name .. ">" .. " (" .. amount .. " / " .. capacity .. ")"
  else
    return "<" .. name .. ">" .. " (" .. amount .. ")"
  end
end

function FluidStack.set_name(fluid_stack, name)
  assert(fluid_stack)
  return { name = name, amount = fluid_stack.amount }
end

function FluidStack.set_amount(fluid_stack, new_amount)
  assert(fluid_stack)
  return { name = fluid_stack.name, amount = new_amount }
end

function FluidStack.inc_amount(fluid_stack, amount)
  return FluidStack.set_amount(fluid_stack, math.max(0, fluid_stack.amount + amount))
end

function FluidStack.dec_amount(fluid_stack, amount)
  return FluidStack.inc_amount(fluid_stack, -amount)
end

function FluidStack.merge(a, ...)
  assert(a, "expected a fluid stack")
  local result = { name = FluidRegistry.normalize_fluid_name(a.name), amount = a.amount }
  for _,b in ipairs({...}) do
    FluidRegistry.normalize_fluid_name(b.name)
    if not result.name or b.name == result.name then
      result.amount = result.amount + b.amount
    end
  end
  return result
end

function FluidStack.presence(fluid_stack)
  if fluid_stack and fluid_stack.amount > 0 then
    return fluid_stack
  else
    return nil
  end
end

yatm_fluids.FluidStack = FluidStack
