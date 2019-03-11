--[[
FluidsInterface

@callback get(self, pos, dir, node) :: FluidStack
@callback replace(self, pos, dir, node, fluid_stack :: FluidStack, commit :: boolean)
@callback fill(self, pos, dir, node, fluid_stack :: FluidStack, commit :: boolean)
@callback drain(self, pos, dir, node, fluid_stack :: FluidStack, commit :: boolean)
]]

local function default_on_fluid_changed(self, pos, dir, new_stack)
  -- Do nothing
end

function yatm_core.new_fluids_interface()
  return {
    on_fluid_changed = default_on_fluid_changed,
  }
end

function yatm_core.new_simple_fluids_interface(tank_name, capacity)
  local fluids_interface = {
    capacity = capacity,
    tank_name = tank_name,
    on_fluid_changed = default_on_fluid_changed,
  }

  function fluids_interface:get(pos, dir)
    local meta = minetest.get_meta(pos)
    local stack = yatm_core.fluids.get_fluid(meta, self.tank_name)
    return stack
  end

  function fluids_interface:replace(pos, dir, new_stack, commit)
    local meta = minetest.get_meta(pos)
    local stack, new_stack = yatm_core.fluids.set_fluid(meta,
      self.tank_name,
      new_stack,
      commit)
    if commit then
      self:on_fluid_changed(pos, dir, new_stack)
    end
    return stack
  end

  function fluids_interface:fill(pos, dir, fluid_stack, commit)
    local meta = minetest.get_meta(pos)
    local stack, new_stack = yatm_core.fluids.fill_fluid(meta,
      self.tank_name,
      fluid_stack,
      self.capacity, self.capacity, commit)
    if commit then
      self:on_fluid_changed(pos, dir, new_stack)
    end
    return stack
  end

  function fluids_interface:drain(pos, dir, fluid_stack, commit)
    local meta = minetest.get_meta(pos)
    local stack, new_stack = yatm_core.fluids.drain_fluid(meta,
      self.tank_name,
      fluid_stack,
      self.capacity, self.capacity, commit)
    if commit then
      self:on_fluid_changed(pos, dir, new_stack)
    end
    return stack
  end

  return fluids_interface
end

function yatm_core.new_directional_fluids_interface(get_fluid_tank_name)
  local fluids_interface = {
    get_fluid_tank_name = get_fluid_tank_name,
    on_fluid_changed = default_on_fluid_changed,
  }

  function fluids_interface:get(pos, dir)
    local meta = minetest.get_meta(pos)
    local tank_name, _capacity = self:get_fluid_tank_name(pos, dir)
    if tank_name then
      local stack = yatm_core.fluids.get_fluid(meta, tank_name)
      return stack
    end
    return nil
  end

  function fluids_interface:replace(pos, dir, fluid_stack, commit)
    local meta = minetest.get_meta(pos)
    local tank_name, _capacity = self:get_fluid_tank_name(pos, dir)
    if tank_name then
      local stack, new_stack = yatm_core.fluids.set_fluid(meta,
        tank_name,
        fluid_stack,
        commit)
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    end
    return nil
  end

  function fluids_interface:fill(pos, dir, fluid_stack, commit)
    local meta = minetest.get_meta(pos)
    local tank_name, capacity = self:get_fluid_tank_name(pos, dir)
    if tank_name then
      local stack, new_stack = yatm_core.fluids.fill_fluid(meta,
        tank_name,
        fluid_stack,
        capacity, capacity, commit)
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    end
    return nil
  end

  function fluids_interface:drain(pos, dir, fluid_stack, commit)
    local meta = minetest.get_meta(pos)
    local tank_name, capacity = self:get_fluid_tank_name(pos, dir)
    if tank_name then
      local stack, new_stack = yatm_core.fluids.drain_fluid(meta,
        tank_name,
        fluid_stack,
        capacity, capacity, commit)
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    end
    return nil
  end

  return fluids_interface
end
