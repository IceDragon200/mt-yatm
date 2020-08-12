--[[
FluidExchange is a utility module built upon FluidMeta and FluidTanks

It provides functions for transfering from one to the other, as well as swapping.

@type meta_config_t :: {
  tank_name = string,
  capacity = integer,
  bandwidth = integer,
}
]]
local FluidMeta = assert(yatm_fluids.FluidMeta)
local FluidTanks = assert(yatm_fluids.FluidTanks)

local FluidExchange = {}

--
-- @spec transfer_from_meta_to_tank(Vector3.t, Direction.code, FluidStack.t,
--                                  Vector3.t, Direction.code, boolean)
function FluidExchange.transfer_from_tank_to_tank(from_pos, from_face, fluid_stack,
                                                  to_pos, to_face, commit)
  -- the first drain is always a non-commit,
  -- this ensures that the fluid exists in the container in question
  local sdrained_fluid = FluidTanks.drain_fluid(from_pos, from_face, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    -- now, we'll attempt to fill the tank with the given fluid, commit is used this time around
    local used_fluid = FluidTanks.fill_fluid(to_pos, to_face, sdrained_fluid, commit)
    if used_fluid and used_fluid.amount > 0 then
      -- Commit is used here as well
      local filled_fluid = FluidTanks.drain_fluid(from_pos, from_face, fluid_stack, commit)
      return filled_fluid
    end
  end
  return nil
end

--
-- @spec FluidExchange:transfer_from_meta_to_tank(IMetaRef.t, meta_config_t, FluidStack.t,
--                                                Vector3.t, Direction.code, boolean)
--
function FluidExchange.transfer_from_meta_to_tank(meta, meta_config, fluid_stack,
                                                  tank_pos, tank_face, commit)
  -- the first drain is always a non-commit,
  -- this ensures that the fluid exists in the container in question
  local sdrained_fluid = FluidMeta.drain_fluid(meta, meta_config.tank_name, fluid_stack,
                                               meta_config.bandwidth, meta_config.capacity, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    -- now, we'll attempt to fill the tank with the given fluid, commit is used this time around
    local used_fluid = FluidTanks.fill_fluid(tank_pos, tank_face, sdrained_fluid, commit)
    if used_fluid and used_fluid.amount > 0 then
      -- Commit is used here as well
      local filled_fluid = FluidMeta.drain_fluid(meta, meta_config.tank_name, used_fluid,
                                                 meta_config.bandwidth, meta_config.capacity,
                                                 commit)
      return filled_fluid
    end
  end
  return nil
end

--
-- @spec FluidExchange:transfer_from_tank_to_meta(Vector3.t, Direction.code, FluidStack.t,
--                                                IMetaRef.t, meta_config_t, boolean)
--
function FluidExchange.transfer_from_tank_to_meta(tank_pos, tank_face, fluid_stack,
                                                  meta, meta_config, commit)
  local sdrained_fluid = FluidTanks.drain_fluid(tank_pos, tank_face, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid = FluidMeta.fill_fluid(meta, meta_config.tank_name, sdrained_fluid,
                                            meta_config.bandwidth, meta_config.capacity, commit)
    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidTanks.drain_fluid(tank_pos, tank_face, fluid_stack, commit)
      return drained_fluid
    end
  end
  return nil
end

--
--
-- @spec transfer_from_meta_to_meta(MetaRef, meta_config, fluid_stack,
--                                  MetaRef, meta_config, boolean) :: FluidStack
function FluidExchange.transfer_from_meta_to_meta(from_meta, from_meta_config, fluid_stack,
                                                  to_meta, to_meta_config, commit)
  local sdrained_fluid = FluidMeta.drain_fluid(from_meta,
                                               from_meta_config.tank_name,
                                               fluid_stack,
                                               from_meta_config.bandwidth,
                                               from_meta_config.capacity,
                                               false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid = FluidMeta.fill_fluid(to_meta,
                                            to_meta_config.tank_name,
                                            sdrained_fluid,
                                            to_meta_config.bandwidth,
                                            to_meta_config.capacity,
                                            commit)
    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidMeta.drain_fluid(from_meta,
                                                  from_meta_config.tank_name,
                                                  fluid_stack,
                                                  from_meta_config.bandwidth,
                                                  from_meta_config.capacity,
                                                  commit)
      return drained_fluid
    end
  end
end

yatm_fluids.FluidExchange = FluidExchange
