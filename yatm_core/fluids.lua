local FluidStack = assert(yatm_core.FluidStack)

local fluids = {
  node_name_to_fluid_name = {},
}

function fluids.register(name, def)
  assert(name, "requires a name")
  assert(def, "requires a definition")
  if def.node and def.node.source then
    fluids.node_name_to_fluid_name[def.node.source] = name
  end
  def.name = name
  -- force the definition into the fluid group
  yatm_core.groups.put_item(def, "fluid", 1)
  yatm_core.measurable.register(fluids, name, def)
end

--[[
@spec fluids.get_item_fluid_name(String.t) :: String.t | nil
]]
function fluids.get_item_fluid_name(item_name)
  return fluids.node_name_to_fluid_name[item_name]
end

function fluids.is_valid_name(name)
  -- A fluid name must not be nil, empty or is a group name
  return name ~= nil and name ~= "" and not yatm_core.string_starts_with(name, "group:")
end

function fluids.can_replace(dest_name, src_name, amount)
  return (dest_name == nil or dest_name == "" or amount == 0) and
    fluids.is_valid_name(src_name)
end

--[[
Determines if fluid name A matches fluid name B, or if they are in a particular group

Usage:

```lua
yatm_core.fluids.matches(fluid_name_or_group_name, fluid_name_or_group_name2) # => fluid_name :: String.t | nil
yatm_core.fluids.matches("group:water", "default:water") # => "default:water"
yatm_core.fluids.matches("group:steam", "yatm_core:steam") # => "yatm_core:steam"
yatm_core.fluids.matches("group:lava", "yatm_core:steam") # => nil
yatm_core.fluids.matches("group:lava", "group:lava") # => nil # you can't match groups, only fluid names with groups
```

Args:
* `a :: String.t` - a fluid name or group name
* `b :: String.t` - a fluid name or group name

Returns:
* `fluid_name :: String.t | nil` - the correct fluid name OR nil if no match was performed
]]
function fluids.matches(a, b)
  if yatm_core.string_starts_with(a, "group:") then
    -- We can't match group to group, since it has to return a valid name
    if b ~= "*" and not yatm_core.string_starts_with(b, "group:") then
      local group = string.sub(a, #"group:" + 1)
      local members = yatm_core.measurable.members_of(fluids, group)
      if members and members[b] then
        return b
      end
    end
    return nil
  elseif yatm_core.string_starts_with(b, "group:") then
    if a == "*" then
      return nil
    end
    local group = string.sub(b, #"group:" + 1)
    local members = yatm_core.measurable.members_of(fluids, group)
    if members and members[a] then
      return a
    end
    return nil
  elseif a == "*" and b == "*" then
    return nil
  elseif a == "*" then
    return b
  elseif b == "*" then
    return a
  elseif a == b then
    return a
  else
    return nil
  end
end

function fluids.set_amount(meta, key, amount, commit)
  local existing_amount = yatm_core.measurable.get_measurable_amount(meta, key)
  local new_amount = math.max(amount, 0);
  if commit then
    yatm_core.measurable.set_measurable_amount(meta, key, new_amount)
  end
  return new_amount - existing_amount, new_amount
end

function fluids.decrease_amount(meta, key, amount, commit)
  local existing_amount = yatm_core.measurable.get_measurable_amount(meta, key)
  local new_amount = math.max(existing_amount - amount, 0);
  if commit then
    yatm_core.measurable.set_measurable_amount(meta, key, new_amount)
  end
  local decreased = existing_amount - new_amount
  return decreased, new_amount
end

function fluids.increase_amount(meta, key, amount, capacity, commit)
  local existing_amount = yatm_core.measurable.get_measurable_amount(meta, key)
  local new_amount
  if capacity then
    new_amount = math.min(existing_amount + amount, capacity)
  else
    new_amount = existing_amount + amount
  end
  if commit then
    yatm_core.measurable.set_measurable_amount(meta, key, new_amount)
  end
  return new_amount - existing_amount, new_amount
end

function fluids.consume_amount(meta, key, amount, bandwidth, commit)
  return fluids.decrease_amount(meta, key, math.min(bandwidth, amount), commit)
end

function fluids.receive_amount(meta, key, amount, bandwidth, capacity, commit)
  return fluids.increase_amount(meta, key, math.min(bandwidth, amount), capacity, commit)
end

function fluids.get_fluid(meta, key)
  local fluid_stack = yatm_core.measurable.get_measurable(meta, key)
  return FluidStack.presence(fluid_stack)
end

function fluids.set_fluid(meta, key, fluid_stack, commit)
  assert(fluid_stack, "expected a fluid stack")
  local src_fluid_name = fluid_stack.name
  local dest_fluid_name = yatm_core.measurable.get_measurable_name(meta, key)
  if dest_fluid_name ~= src_fluid_name then
    dest_fluid_name = src_fluid_name
    if commit then
      yatm_core.measurable.set_measurable_name(fluids, meta, key, src_fluid_name)
    end
  end
  local set_amount, new_amount = fluids.set_amount(meta, key, fluid_stack.amount, commit)
  return FluidStack.new(dest_fluid_name, set_amount), FluidStack.new(dest_fluid_name, new_amount)
end

function fluids.decrease_fluid(meta, key, fluid_stack, capacity, commit)
  local src_fluid_name = fluid_stack.name
  local dest_fluid_name = yatm_core.measurable.get_measurable_name(meta, key)
  if fluids.is_valid_name(dest_fluid_name) then
    local match_name = src_fluid_name
    if match_name then
      match_name = fluids.matches(dest_fluid_name, match_name)
    end
    if match_name then
      local set_amount, new_amount = fluids.decrease_amount(meta, key, fluid_stack.amount, commit)
      return FluidStack.new(dest_fluid_name, set_amount), FluidStack.new(dest_fluid_name, new_amount)
    end
  end
  return nil, fluids.get_fluid(meta, key)
end

function fluids.increase_fluid(meta, key, fluid_stack, capacity, commit)
  local src_fluid_name = fluid_stack.name
  assert(src_fluid_name ~= nil or src_fluid_name ~= "", "expected a source fluid name, got " .. dump(src_fluid_name))
  local dest_fluid_name = yatm_core.measurable.get_measurable_name(meta, key)
  local fluid_amount = yatm_core.measurable.get_measurable_amount(meta, key)
  if fluids.can_replace(dest_fluid_name, src_fluid_name, fluid_amount) then
    dest_fluid_name = src_fluid_name
    if commit then
      yatm_core.measurable.set_measurable_name(fluids, meta, key, dest_fluid_name)
    end
  end
  local match_name = fluids.matches(dest_fluid_name, src_fluid_name)
  if match_name then
    local set_amount, new_amount = fluids.increase_amount(meta, key, fluid_stack.amount, capacity, commit)
    return FluidStack.new(match_name, set_amount), FluidStack.new(dest_fluid_name, new_amount)
  else
    return nil, fluids.get_fluid(meta, key)
  end
end

function fluids.drain_fluid(meta, key, fluid_stack, bandwidth, capacity, commit)
  return fluids.decrease_fluid(meta, key, FluidStack.set_amount(fluid_stack, math.min(bandwidth, fluid_stack.amount)), capacity, commit)
end

function fluids.fill_fluid(meta, key, fluid_stack, bandwidth, capacity, commit)
  return fluids.increase_fluid(meta, key, FluidStack.set_amount(fluid_stack, math.min(bandwidth, fluid_stack.amount)), capacity, commit)
end

function fluids.inspect(meta, key)
  local fluid_stack = fluids.get_fluid(meta, key)
  if fluid_stack then
    return FluidStack.to_string(fluid_stack)
  else
    return "nil"
  end
end

yatm_core.fluids = fluids
