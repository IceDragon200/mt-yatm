--[[
FluidInterface

@callback get(self, pos, dir, node) :: FluidStack
@callback replace(self, pos, dir, node, fluid_stack :: FluidStack, commit :: boolean)
@callback fill(self, pos, dir, node, fluid_stack :: FluidStack, commit :: boolean)
@callback drain(self, pos, dir, node, fluid_stack :: FluidStack, commit :: boolean)
@callback on_fluid_changed(pos, dir, fluid_stack :: FluidStack)
]]
local FluidMeta = assert(yatm_fluids.FluidMeta)

local FluidInterface = {}

local function default_on_fluid_changed(self, pos, dir, new_stack)
  -- Do nothing
end

function FluidInterface.new()
  local fluid_interface = {
    on_fluid_changed = default_on_fluid_changed,
  }

  function fluid_interface:allow_replace(pos, dir, new_stack)
    return true
  end

  function fluid_interface:allow_fill(pos, dir, fluid_stack)
    return true
  end

  function fluid_interface:allow_drain(pos, dir, fluid_stack)
    return true
  end

  return fluid_interface
end

function FluidInterface.new_simple(tank_name, capacity)
  local fluid_interface = FluidInterface.new()

  fluid_interface.capacity = capacity
  fluid_interface.bandwidth = capacity
  fluid_interface.tank_name = tank_name

  function fluid_interface:get(pos, dir)
    local meta = minetest.get_meta(pos)
    local stack = FluidMeta.get_fluid(meta, self.tank_name)
    return stack
  end

  function fluid_interface:replace(pos, dir, new_stack, commit)
    if self:allow_replace(pos, dir, new_stack) then
      local meta = minetest.get_meta(pos)
      local stack, new_stack = FluidMeta.set_fluid(meta,
        self.tank_name,
        new_stack,
        commit)
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    else
      return nil
    end
  end

  function fluid_interface:fill(pos, dir, fluid_stack, commit)
    if self:allow_fill(pos, dir, fluid_stack) then
      local meta = minetest.get_meta(pos)
      local stack, new_stack = FluidMeta.fill_fluid(meta,
        self.tank_name,
        fluid_stack,
        self.bandwidth, self.capacity, commit)
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    end
  end

  function fluid_interface:drain(pos, dir, fluid_stack, commit)
    if self:allow_drain(pos, dir, fluid_stack) then
      local meta = minetest.get_meta(pos)
      local stack, new_stack = FluidMeta.drain_fluid(meta,
        self.tank_name,
        fluid_stack,
        self.bandwidth, self.capacity, commit)
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    end
  end

  return fluid_interface
end

function FluidInterface.new_directional(get_fluid_tank_name)
  local fluid_interface = FluidInterface.new()
  fluid_interface.get_fluid_tank_name = get_fluid_tank_name
  fluid_interface.on_fluid_changed = default_on_fluid_changed

  function fluid_interface:get(pos, dir)
    local meta = minetest.get_meta(pos)
    local tank_name, _capacity = self:get_fluid_tank_name(pos, dir)
    if tank_name then
      local stack = FluidMeta.get_fluid(meta, tank_name)
      return stack
    end
    return nil
  end

  function fluid_interface:replace(pos, dir, fluid_stack, commit)
    if self:allow_replace(pos, dir, fluid_stack) then
      local meta = minetest.get_meta(pos)
      local tank_name, _capacity = self:get_fluid_tank_name(pos, dir)
      if tank_name then
        local stack, new_stack = FluidMeta.set_fluid(meta,
          tank_name,
          fluid_stack,
          commit)
        if commit then
          self:on_fluid_changed(pos, dir, new_stack)
        end
        return stack
      end
    end
    return nil
  end

  function fluid_interface:fill(pos, dir, fluid_stack, commit)
    if self:allow_fill(pos, dir, fluid_stack) then
      local meta = minetest.get_meta(pos)
      local tank_name, capacity = self:get_fluid_tank_name(pos, dir)
      if tank_name then
        local stack, new_stack = FluidMeta.fill_fluid(meta,
          tank_name,
          fluid_stack,
          capacity, capacity, commit)
        if commit then
          self:on_fluid_changed(pos, dir, new_stack)
        end
        return stack
      end
    end
    return nil
  end

  function fluid_interface:drain(pos, dir, fluid_stack, commit)
    if self:allow_drain(pos, dir, fluid_stack) then
      local meta = minetest.get_meta(pos)
      local tank_name, capacity = self:get_fluid_tank_name(pos, dir)
      if tank_name then
        local stack, new_stack = FluidMeta.drain_fluid(meta,
          tank_name,
          fluid_stack,
          capacity, capacity, commit)
        if commit then
          self:on_fluid_changed(pos, dir, new_stack)
        end
        return stack
      end
    end
    return nil
  end

  return fluid_interface
end

yatm_fluids.FluidInterface = FluidInterface
