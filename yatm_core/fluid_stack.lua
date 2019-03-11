local FluidStack = {}

function FluidStack.new(name, amount)
  return { name = name, amount = amount or 0 }
end

function FluidStack.new_group(group_name, amount)
  return FluidStack.new("group:" .. group_name, amount)
end

function FluidStack.new_wildcard(amount)
  return FluidStack.new("*", amount)
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
  local result = { name = a.name, amount = a.amount }
  for _,b in ipairs({...}) do
    if b.name == result.name then
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

yatm_core.FluidStack = FluidStack
