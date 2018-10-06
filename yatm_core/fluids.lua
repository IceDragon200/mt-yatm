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
  yatm_core.measurable.register(name, def)
end

function fluids.get_item_fluid(name)
  return fluids.node_name_to_fluid_name[name]
end

function fluids.new_stack(name, amount)
  return { name = name, amount = amount }
end

function fluids.is_valid_name(name)
  return name ~= nil and name ~= ""
end

function fluids.can_replace(name, amount)
  return name == nil or name == "" or amount == 0
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
  local stack = yatm_core.measurable.get_measurable(meta, key)
  if fluids.is_valid_name(stack.name) and stack.amount > 0 then
    return stack
  else
    return nil
  end
end

function fluids.set_fluid(meta, key, src_fluid_name, amount, commit)
  local dest_fluid_name = yatm_core.measurable.get_measurable_name(meta, key)
  if dest_fluid_name ~= src_fluid_name then
    dest_fluid_name = src_fluid_name
    if commit then
      yatm_core.measurable.set_measurable_name(meta, key, src_fluid_name)
    end
  end
  local set_amount, new_amount = fluids.set_amount(meta, key, amount, commit)
  return fluids.new_stack(dest_fluid_name, set_amount), new_amount
end

function fluids.decrease_fluid(meta, key, src_fluid_name, amount, capacity, commit)
  local dest_fluid_name = yatm_core.measurable.get_measurable_name(meta, key)
  if fluids.is_valid_name(dest_fluid_name) then
    if src_fluid_name == nil or dest_fluid_name == src_fluid_name then
      local set_amount, new_amount = fluids.decrease_amount(meta, key, amount, commit)
      return fluids.new_stack(dest_fluid_name, set_amount), new_amount
    end
  end
  return nil, yatm_core.measurable.get_measurable_amount(meta, key)
end

function fluids.increase_fluid(meta, key, src_fluid_name, amount, capacity, commit)
  assert(src_fluid_name ~= nil and src_fluid_name ~= "", "expected a source fluid name, got " .. dump(src_fluid_name))
  local dest_fluid_name = yatm_core.measurable.get_measurable_name(meta, key)
  local fluid_amount = yatm_core.measurable.get_measurable_amount(meta, key)
  if fluids.can_replace(dest_fluid_name, fluid_amount) then
    dest_fluid_name = src_fluid_name
    if commit then
      yatm_core.measurable.set_measurable_name(meta, key, dest_fluid_name)
    end
  end
  if dest_fluid_name == src_fluid_name then
    local set_amount, new_amount = fluids.increase_amount(meta, key, amount, capacity, commit)
    return fluids.new_stack(dest_fluid_name, set_amount), new_amount
  else
    return nil, yatm_core.measurable.get_measurable_amount(meta, key)
  end
end

function fluids.drain_fluid(meta, key, src_fluid_name, amount, bandwidth, capacity, commit)
  return fluids.decrease_fluid(meta, key, src_fluid_name, math.min(bandwidth, amount), capacity, commit)
end

function fluids.fill_fluid(meta, key, src_fluid_name, amount, bandwidth, capacity, commit)
  return fluids.increase_fluid(meta, key, src_fluid_name, math.min(bandwidth, amount), capacity, commit)
end

fluids.register("default:water", {
  node = {
    source = "default:water_source",
    flowing = "default:water_flowing",
  },
})

fluids.register("default:river_water", {
  node = {
    source = "default:river_water_source",
    flowing = "default:river_water_flowing",
  },
})

fluids.register("default:lava_water", {
  node = {
    source = "default:lava_source",
    flowing = "default:lava_flowing",
  },
})

yatm_core.fluids = fluids
