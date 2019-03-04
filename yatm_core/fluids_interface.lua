function yatm_core.new_simple_fluids_interface(tank_name, capacity)
  local fluids_interface = {
    capacity = capacity,
    tank_name = tank_name,
  }

  function fluids_interface.get(pos, dir, node)
    local meta = minetest.get_meta(pos)
    local stack = yatm_core.fluids.get_fluid(meta, tank_name)
    return stack
  end

  function fluids_interface.replace(pos, dir, node, fluid_name, amount, commit)
    local meta = minetest.get_meta(pos)
    local stack, new_amount = yatm_core.fluids.set_fluid(meta, tank_name, fluid_name, amount, commit)
    if commit then
      yatm_core.fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
    end
    return stack
  end

  function fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
    local meta = minetest.get_meta(pos)
    local stack, new_amount = yatm_core.fluids.fill_fluid(meta, tank_name, fluid_name, amount, capacity, capacity, commit)
    if commit then
      yatm_core.fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
    end
    return stack
  end

  function fluids_interface.drain(pos, dir, node, fluid_name, amount, commit)
    local meta = minetest.get_meta(pos)
    local stack, new_amount = yatm_core.fluids.drain_fluid(meta, tank_name, fluid_name, amount, capacity, capacity, commit)
    if commit then
      yatm_core.fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
    end
    return stack
  end

  return fluids_interface
end

function yatm_core.new_directional_fluids_interface(get_fluid_tank_name)
  local fluids_interface = {}

  function fluids_interface.get(pos, dir, node)
    local meta = minetest.get_meta(pos)
    local tank_name, _capacity = get_fluid_tank_name(pos, dir, node)
    if tank_name then
      local stack = yatm_core.fluids.get_fluid(meta, tank_name)
      return stack
    end
    return nil
  end

  function fluids_interface.replace(pos, dir, node, fluid_name, amount, commit)
    local meta = minetest.get_meta(pos)
    local tank_name, _capacity = get_fluid_tank_name(pos, dir, node)
    if tank_name then
      local stack, new_amount = yatm_core.fluids.set_fluid(meta, tank_name, fluid_name, amount, commit)
      if commit then
        yatm_core.fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
      end
      return stack
    end
    return nil
  end

  function fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
    local meta = minetest.get_meta(pos)
    local tank_name, capacity = get_fluid_tank_name(pos, dir, node)
    if tank_name then
      local stack, new_amount = yatm_core.fluids.fill_fluid(meta, tank_name, fluid_name, amount, capacity, capacity, commit)
      if commit then
        yatm_core.fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
      end
      return stack
    end
    return nil
  end

  function fluids_interface.drain(pos, dir, node, fluid_name, amount, commit)
    local meta = minetest.get_meta(pos)
    local tank_name, capacity = get_fluid_tank_name(pos, dir, node)
    if tank_name then
      local stack, new_amount = yatm_core.fluids.drain_fluid(meta, tank_name, fluid_name, amount, capacity, capacity, commit)
      if commit then
        yatm_core.fluid_tanks.trigger_on_fluid_changed(pos, dir, node, stack, new_amount, capacity)
      end
      return stack
    end
    return nil
  end

  return fluids_interface
end
