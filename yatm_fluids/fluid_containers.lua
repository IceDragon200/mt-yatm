--
-- Utility functions for manipulating fluid containers
--
local FluidMeta = assert(yatm_fluids.FluidMeta)
local FluidStack = assert(yatm_fluids.FluidStack)

local FluidContainers = {}

-- @spec is_fluid_container(item_stack: ItemStack): Boolean
function FluidContainers.is_fluid_container(item_stack)
  local def = item_stack:get_definition()
  local fluid_container = def.fluid_container

  if fluid_container then
    return true
  end

  return false
end

-- @spec is_empty(item_stack: ItemStack): Boolean
function FluidContainers.is_empty(item_stack)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.is_empty(
      meta,
      fluid_container.key
    )
  end

  return nil
end

-- @spec get_fluid_stack(item_stack: ItemStack): FluidStack | nil
function FluidContainers.get_fluid_stack(item_stack)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.get_fluid_stack(
      meta,
      fluid_container.key
    )
  end

  return nil
end

-- @spec set_fluid(
--   item_stack: ItemStack,
--   fluid_stack: FluidStack,
--   commit: Boolean
-- ): (FluidStack | nil, FluidStack)
function FluidContainers.set_fluid(item_stack, fluid_stack, commit)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.set_fluid(
      meta,
      fluid_container.key,
      fluid_stack,
      commit
    )
  end

  return nil, fluid_stack
end

-- @spec decrease_fluid(
--   item_stack: ItemStack,
--   fluid_stack: FluidStack,
--   commit: Boolean
-- ): (FluidStack | nil, FluidStack)
function FluidContainers.decrease_fluid(item_stack, fluid_stack, commit)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.decrease_fluid(
      meta,
      fluid_container.key,
      fluid_stack,
      fluid_container.capacity,
      commit
    )
  end

  return nil, fluid_stack
end

-- @spec increase_fluid(
--   item_stack: ItemStack,
--   fluid_stack: FluidStack,
--   commit: Boolean
-- ): (FluidStack | nil, FluidStack)
function FluidContainers.increase_fluid(item_stack, fluid_stack, commit)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.increase_fluid(
      meta,
      fluid_container.key,
      fluid_stack,
      fluid_container.capacity,
      commit
    )
  end

  return nil, fluid_stack
end

-- @spec drain_fluid(
--   item_stack: ItemStack,
--   fluid_stack: FluidStack,
--   commit: Boolean
-- ): (FluidStack | nil, FluidStack)
function FluidContainers.drain_fluid(item_stack, fluid_stack, commit)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.drain_fluid(
      meta,
      fluid_container.key,
      fluid_stack,
      fluid_container.bandwidth or fluid_container.capacity,
      fluid_container.capacity,
      commit
    )
  end

  return nil, fluid_stack
end

-- @spec fill_fluid(
--   item_stack: ItemStack,
--   fluid_stack: FluidStack,
--   commit: Boolean
-- ): (FluidStack | nil, FluidStack)
function FluidContainers.fill_fluid(item_stack, fluid_stack, commit)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.fill_fluid(
      meta,
      fluid_container.key,
      fluid_stack,
      fluid_container.bandwidth or fluid_container.capacity,
      fluid_container.capacity,
      commit
    )
  end

  return nil, fluid_stack
end

-- @spec inspect(item_stack: ItemStack): String | nil
function FluidContainers.inspect(item_stack)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.inspect(meta, fluid_container.key)
  end

  return nil
end

-- @spec to_infotext(item_stack: ItemStack): String | nil
function FluidContainers.to_infotext(item_stack)
  local def = item_stack:get_definition()
  local meta = item_stack:get_meta()
  local fluid_container = def.fluid_container

  if fluid_container then
    return FluidMeta.to_infotext(meta, fluid_container.key, fluid_container.capacity)
  end

  return nil
end

yatm_fluids.FluidContainers = FluidContainers
