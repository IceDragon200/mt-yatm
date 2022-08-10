-- @namespace yatm_fluids.FluidInterface
--
-- FluidInterface
-- @version "1.1.0"
--
-- @since "1.0.0"
-- @type get: function(self, pos, dir, node) => FluidStack
--
-- @since "1.1.0"
-- @type get_capacity: function(self, pos, dir, node) => Integer
--
-- @since "1.0.0"
-- @type replace: function(self, pos, dir, node, fluid_stack: FluidStack, commit: Boolean) => void
--
-- @since "1.0.0"
-- @type fill: function(self, pos, dir, node, fluid_stack: FluidStack, commit: Boolean) => void
--
-- @since "1.0.0"
-- @type drain: function(self, pos, dir, node, fluid_stack: FluidStack, commit: Boolean) => void
--
-- @since "1.0.0"
-- @type on_fluid_changed: function(self, pos, dir, fluid_stack: FluidStack) => void
local FluidMeta = assert(yatm_fluids.FluidMeta)

local FluidInterface = {
  version = "1.1.0",
}

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
    _private = {},
    on_fluid_changed = default_on_fluid_changed,
    allow_replace = default_allow_replace,
    allow_fill = default_allow_fill,
    allow_drain = default_allow_drain,
  }

  return fluid_interface
end

local function default_simple_get(self, pos, dir)
  local meta = minetest.get_meta(pos)
  local stack = FluidMeta.get_fluid_stack(meta, self._private.tank_name)
  if stack then
    return stack
  end
  return nil, "nothing"
end

local function default_simple_get_capacity(self, _pos, _dir)
  return self._private.capacity
end

local function default_simple_replace(self, pos, dir, new_stack, commit)
  local allowed, reason = self:allow_replace(pos, dir, new_stack)
  if allowed then
    local meta = minetest.get_meta(pos)
    local stack

    stack, new_stack = FluidMeta.set_fluid(meta,
      self._private.tank_name,
      new_stack,
      commit)

    if commit then
      self:on_fluid_changed(pos, dir, new_stack)
    end
    return stack
  end
  return nil, reason
end

local function default_simple_fill(self, pos, dir, fluid_stack, commit)
  local allowed, reason = self:allow_fill(pos, dir, fluid_stack)
  if allowed then
    local meta = minetest.get_meta(pos)
    local stack, new_stack = FluidMeta.fill_fluid(meta,
      self._private.tank_name,
      fluid_stack,
      self._private.bandwidth, self:get_capacity(pos, dir), commit)
    if commit then
      self:on_fluid_changed(pos, dir, new_stack)
    end
    return stack
  end
  return nil, reason
end

local function default_simple_drain(self, pos, dir, fluid_stack, commit)
  local allowed, reason = self:allow_drain(pos, dir, fluid_stack)
  if allowed then
    local meta = minetest.get_meta(pos)
    local stack, new_stack = FluidMeta.drain_fluid(meta,
      self._private.tank_name,
      fluid_stack,
      self._private.bandwidth, self:get_capacity(pos, dir), commit)
    if commit then
      self:on_fluid_changed(pos, dir, new_stack)
    end
    return stack
  end
  return nil, reason
end

function FluidInterface.new_simple(tank_name, capacity)
  assert(tank_name, "expecetd a tank name")
  assert(capacity, "expecetd a capacity")
  local fluid_interface = FluidInterface.new()

  fluid_interface._private = {
    capacity = capacity,
    bandwidth = capacity,
    tank_name = tank_name,
  }

  fluid_interface.get = default_simple_get
  fluid_interface.get_capacity = default_simple_get_capacity
  fluid_interface.replace = default_simple_replace
  fluid_interface.fill = default_simple_fill
  fluid_interface.drain = default_simple_drain

  return fluid_interface
end

local function default_directional_get(self, pos, dir, _node)
  local meta = minetest.get_meta(pos)
  local tank_name, _capacity = self:get_fluid_tank_name(pos, dir)
  if tank_name then
    local stack = FluidMeta.get_fluid_stack(meta, tank_name)
    return stack
  end
  return nil, "nothing"
end

local function default_directional_get_capacity(self, pos, dir, _node)
  local meta = minetest.get_meta(pos)
  local tank_name, capacity = self:get_fluid_tank_name(pos, dir)
  if tank_name then
    return capacity
  end
  return nil, "no capacity"
end

local function default_directional_replace(self, pos, dir, fluid_stack, commit)
  local allowed, reason = self:allow_replace(pos, dir, fluid_stack)
  if allowed then
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
    return nil, "no tank"
  end
  return nil, reason
end

local function default_directional_fill(self, pos, dir, fluid_stack, commit)
  local allowed, reason = self:allow_fill(pos, dir, fluid_stack)
  if allowed then
    local meta = minetest.get_meta(pos)
    local tank_name, capacity = self:get_fluid_tank_name(pos, dir)
    if not capacity then
      local node = minetest.get_node_or_nil(pos)
      if node then
        error(
          "expected fluid tank capacity for node=" .. node.name .. " at pos=" .. minetest.pos_to_string(pos)
        )
      else
        error(
          "expected fluid tank capacity for at pos=" .. minetest.pos_to_string(pos)
        )
      end
    end

    if tank_name then
      local stack, new_stack = FluidMeta.fill_fluid(
        meta,
        tank_name,
        fluid_stack,
        capacity,
        capacity,
        commit
      )
      if commit then
        self:on_fluid_changed(pos, dir, new_stack)
      end
      return stack
    end
    return nil, "no tank"
  end
  return nil, reason
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
    return nil, "no tank"
  end
  return nil
end

function FluidInterface.new_directional(get_fluid_tank_name)
  local fluid_interface = FluidInterface.new()
  fluid_interface._private = {}
  fluid_interface.get_fluid_tank_name = get_fluid_tank_name
  fluid_interface.on_fluid_changed = default_on_fluid_changed

  fluid_interface.get = default_directional_get
  fluid_interface.get_capacity = default_directional_get_capacity
  fluid_interface.replace = default_directional_replace
  fluid_interface.fill = default_directional_fill
  fluid_interface.drain = default_directional_drain

  return fluid_interface
end

yatm_fluids.FluidInterface = FluidInterface
