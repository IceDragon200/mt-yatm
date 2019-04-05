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

local function default_allow_replace(self, pos, dir, new_stack)
  return true
end

local function default_allow_fill(self, pos, dir, fluid_stack)
  return true
end

local function default_allow_drain(self, pos, dir, fluid_stack)
  return true
end

function FluidInterface.new()
  local fluid_interface = {
    on_fluid_changed = default_on_fluid_changed,
    allow_replace = default_allow_replace,
    allow_fill = default_allow_fill,
    allow_drain = default_allow_drain,
  }

  return fluid_interface
end

local function default_simple_get(self, pos, dir)
  local meta = minetest.get_meta(pos)
  local stack = FluidMeta.get_fluid_stack(meta, self.tank_name)
  return stack
end

function default_simple_replace(self, pos, dir, new_stack, commit)
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

function default_simple_fill(self, pos, dir, fluid_stack, commit)
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

function default_simple_drain(self, pos, dir, fluid_stack, commit)
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

function FluidInterface.new_simple(tank_name, capacity)
  local fluid_interface = FluidInterface.new()

  fluid_interface.capacity = capacity
  fluid_interface.bandwidth = capacity
  fluid_interface.tank_name = tank_name

  fluid_interface.get = default_simple_get
  fluid_interface.replace = default_simple_replace
  fluid_interface.fill = default_simple_fill
  fluid_interface.drain = default_simple_drain

  return fluid_interface
end

local function default_directional_get(self, pos, dir)
  local meta = minetest.get_meta(pos)
  local tank_name, _capacity = self:get_fluid_tank_name(pos, dir)
  if tank_name then
    local stack = FluidMeta.get_fluid_stack(meta, tank_name)
    return stack
  end
  return nil
end

local function default_directional_replace(self, pos, dir, fluid_stack, commit)
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

local function default_directional_fill(self, pos, dir, fluid_stack, commit)
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

local function default_directional_drain(self, pos, dir, fluid_stack, commit)
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

function FluidInterface.new_directional(get_fluid_tank_name)
  local fluid_interface = FluidInterface.new()
  fluid_interface.get_fluid_tank_name = get_fluid_tank_name
  fluid_interface.on_fluid_changed = default_on_fluid_changed

  fluid_interface.get = default_directional_get
  fluid_interface.replace = default_directional_replace
  fluid_interface.fill = default_directional_fill
  fluid_interface.drain = default_directional_drain

  return fluid_interface
end

yatm_fluids.FluidInterface = FluidInterface
