--
-- Utility module for operating on MetaRef's regarding fluids
--
local FluidUtil = assert(yatm_fluids.Utils)
local fluid_registry = assert(yatm_fluids.fluid_registry)
local FluidStack = assert(yatm_fluids.FluidStack)
local Measurable = assert(yatm.Measurable)
local FluidMeta = {}

function FluidMeta.set_amount(meta, key, amount, commit)
  local existing_amount = Measurable.get_measurable_amount(meta, key)
  local new_amount = math.max(amount, 0);
  if commit then
    Measurable.set_measurable_amount(meta, key, new_amount)
  end
  return new_amount - existing_amount, new_amount
end

function FluidMeta.decrease_amount(meta, key, amount, commit)
  local existing_amount = Measurable.get_measurable_amount(meta, key)
  local new_amount = math.max(existing_amount - amount, 0);
  if commit then
    Measurable.set_measurable_amount(meta, key, new_amount)
  end
  local decreased = existing_amount - new_amount
  return decreased, new_amount
end

function FluidMeta.increase_amount(meta, key, amount, capacity, commit)
  local existing_amount = Measurable.get_measurable_amount(meta, key)
  local new_amount = 0
  if capacity then
    new_amount = math.min(existing_amount + amount, capacity)
  else
    new_amount = existing_amount + amount
  end
  if commit then
    Measurable.set_measurable_amount(meta, key, new_amount)
  end
  return new_amount - existing_amount, new_amount
end

function FluidMeta.consume_amount(meta, key, amount, bandwidth, commit)
  return FluidMeta.decrease_amount(meta, key, math.min(bandwidth, amount), commit)
end

function FluidMeta.receive_amount(meta, key, amount, bandwidth, capacity, commit)
  return FluidMeta.increase_amount(meta, key, math.min(bandwidth, amount), capacity, commit)
end

function FluidMeta.get_fluid_stack(meta, key)
  assert(meta, "expected a meta ref")
  assert(key, "expected a key")
  local fluid_stack = Measurable.get_measurable(meta, key)
  return FluidStack.presence(fluid_stack)
end

function FluidMeta.set_fluid(meta, key, fluid_stack, commit)
  assert(fluid_stack, "expected a fluid stack")
  local src_fluid_name = fluid_stack.name
  local dest_fluid_name = Measurable.get_measurable_name(meta, key)
  if dest_fluid_name ~= src_fluid_name then
    dest_fluid_name = src_fluid_name
    if commit then
      Measurable.set_measurable_name(fluid_registry, meta, key, src_fluid_name)
    end
  end
  local set_amount, new_amount = FluidMeta.set_amount(meta, key, fluid_stack.amount, commit)
  return FluidStack.new(dest_fluid_name, set_amount), FluidStack.new(dest_fluid_name, new_amount)
end

function FluidMeta.decrease_fluid(meta, key, fluid_stack, capacity, commit)
  local src_fluid_name = fluid_stack.name
  local dest_fluid_name = Measurable.get_measurable_name(meta, key)
  if FluidUtil.is_valid_name(dest_fluid_name) then
    local match_name = src_fluid_name
    if match_name then
      match_name = FluidUtil.matches(dest_fluid_name, match_name)
    end
    if match_name then
      local set_amount, new_amount = FluidMeta.decrease_amount(meta, key, fluid_stack.amount, commit)
      return FluidStack.new(dest_fluid_name, set_amount), FluidStack.new(dest_fluid_name, new_amount)
    end
  end
  return nil, FluidMeta.get_fluid_stack(meta, key)
end

function FluidMeta.increase_fluid(meta, key, fluid_stack, capacity, commit)
  local src_fluid_name = fluid_stack.name
  assert(src_fluid_name ~= nil or src_fluid_name ~= "", "expected a source fluid name, got " .. dump(src_fluid_name))
  local dest_fluid_name = Measurable.get_measurable_name(meta, key)
  local fluid_amount = Measurable.get_measurable_amount(meta, key)
  if FluidUtil.can_replace(dest_fluid_name, src_fluid_name, fluid_amount) then
    dest_fluid_name = src_fluid_name
    if commit then
      Measurable.set_measurable_name(fluid_registry, meta, key, dest_fluid_name)
    end
  end
  local match_name = FluidUtil.matches(dest_fluid_name, src_fluid_name)
  if match_name then
    local set_amount, new_amount = FluidMeta.increase_amount(meta, key, fluid_stack.amount, capacity, commit)
    return FluidStack.new(match_name, set_amount), FluidStack.new(dest_fluid_name, new_amount)
  else
    return nil, FluidMeta.get_fluid_stack(meta, key)
  end
end

function FluidMeta.drain_fluid(meta, key, fluid_stack, bandwidth, capacity, commit)
  return FluidMeta.decrease_fluid(meta, key, FluidStack.set_amount(fluid_stack, math.min(bandwidth, fluid_stack.amount)), capacity, commit)
end

function FluidMeta.fill_fluid(meta, key, fluid_stack, bandwidth, capacity, commit)
  return FluidMeta.increase_fluid(meta, key, FluidStack.set_amount(fluid_stack, math.min(bandwidth, fluid_stack.amount)), capacity, commit)
end

function FluidMeta.room_for_fluid(meta, key, fluid_stack, bandwidth, capacity)
  local used_fluid_stack = FluidMeta.fill_fluid(meta, key, fluid_stack, bandwidth, capacity, false)
  if used_fluid_stack then
    return used_fluid_stack.amount == fluid_stack.amount
  else
    return false
  end
end

function FluidMeta.inspect(meta, key)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, key)
  if fluid_stack then
    return FluidStack.to_string(fluid_stack)
  else
    return "nil"
  end
end

function FluidMeta.to_infotext(meta, key, capacity)
  local fluid_stack = FluidMeta.get_fluid_stack(meta, key)
  return FluidStack.pretty_format(fluid_stack, capacity)
end

yatm_fluids.FluidMeta = FluidMeta
