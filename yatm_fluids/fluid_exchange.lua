local Directions = assert(foundation.com.Directions)
local Vector3 = assert(foundation.com.Vector3)
local FluidMeta = assert(yatm_fluids.FluidMeta)
local FluidTanks = assert(yatm_fluids.FluidTanks)
local FluidContainers = assert(yatm_fluids.FluidContainers)

--- @namespace yatm_fluids.FluidExchange

--- FluidExchange is a utility module built upon FluidMeta and FluidTanks
---
--- It provides functions for transfering from one to the other, as well as swapping.

--- @type FluidMetaConfig: {
---   tank_name: String,
---   capacity: Integer,
---   bandwidth: Integer,
--- }

local FluidExchange = {}

---
--- @since "2.7.0"
--- @spec transfer_from_container_to_container(
---   from_item_stack: ItemStack,
---   fluid_stack: FluidStack,
---   to_item_stack: ItemStack,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_container_to_container(
  from_item_stack,
  fluid_stack,
  to_item_stack,
  commit
)
  local sdrained_fluid = FluidContainers.drain_fluid(from_item_stack, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid =
      FluidContainers.fill_fluid(
        to_item_stack,
        sdrained_fluid,
        commit
      )

    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidContainers.drain_fluid(from_item_stack, used_fluid, commit)
      return drained_fluid
    end
  end
  return nil
end

---
--- @since "2.7.0"
--- @spec transfer_from_container_to_meta(
---   from_item_stack: ItemStack,
---   to_item_stack: ItemStack,
---   meta: IMetaRef,
---   meta_config: FluidMetaConfig,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_container_to_meta(
  from_item_stack,
  fluid_stack,
  meta,
  meta_config,
  commit
)
  local sdrained_fluid = FluidContainers.drain_fluid(from_item_stack, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid =
      FluidMeta.fill_fluid(
        meta, meta_config.tank_name, sdrained_fluid,
        meta_config.bandwidth, meta_config.capacity, commit
      )

    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidContainers.drain_fluid(from_item_stack, used_fluid, commit)
      return drained_fluid
    end
  end
  return nil
end

---
--- @since "2.7.0"
--- @spec transfer_from_container_to_tank(
---   from_item_stack: ItemStack,
---   fluid_stack: FluidStack,
---   to_pos: Vector3,
---   to_face: Direction.code,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_container_to_tank(
  from_item_stack,
  fluid_stack,
  to_pos,
  to_face,
  commit
)
  local sdrained_fluid = FluidContainers.drain_fluid(from_item_stack, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid = FluidTanks.fill_fluid(to_pos, to_face, sdrained_fluid, commit)

    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidContainers.drain_fluid(from_item_stack, used_fluid, commit)
      return drained_fluid
    end
  end
  return nil
end

---
--- @spec transfer_from_tank_to_adjacent_tank(
---   from_pos: Vector3,
---   from_face: Direction.code,
---   fluid_stack: FluidStack,
---   commit: Boolean
--- ): (remaining: FluidStack)
function FluidExchange.transfer_from_tank_to_adjacent_tank(
  from_pos,
  local_dir,
  fluid_stack,
  commit
)
  local node = minetest.get_node_or_nil(from_pos)
  if node then
    local nodedef = minetest.registered_nodes[node.name]
    local dir = local_dir
    if nodedef.paramtype2 == "facedir" then
      dir = Directions.facedir_to_face(node.param2, local_dir)
    end
    local neighbour_pos = Vector3.zero()
    Vector3.add(neighbour_pos, from_pos, Directions.DIR6_TO_VEC3[dir])
    return FluidExchange.transfer_from_tank_to_tank(
      from_pos,
      dir,
      fluid_stack,
      neighbour_pos,
      Directions.invert_dir(dir),
      commit
    )
  end

  return fluid_stack
end

---
--- @since "2.7.0"
--- @spec transfer_from_tank_to_container(
---   from_pos: Vector3,
---   tank_face: Direction.code,
---   fluid_stack: FluidStack,
---   item_stack: ItemStack,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_tank_to_container(
  tank_pos,
  tank_face,
  fluid_stack,
  item_stack,
  commit
)
  local sdrained_fluid = FluidTanks.drain_fluid(tank_pos, tank_face, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid =
      FluidContainers.fill_fluid(
        item_stack,
        sdrained_fluid,
        commit
      )

    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidTanks.drain_fluid(tank_pos, tank_face, used_fluid, commit)
      return drained_fluid
    end
  end
  return nil
end

---
--- @spec transfer_from_tank_to_meta(
---   from_pos: Vector3,
---   tank_face: Direction.code,
---   fluid_stack: FluidStack,
---   meta: IMetaRef,
---   meta_config: FluidMetaConfig,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_tank_to_meta(
  tank_pos,
  tank_face,
  fluid_stack,
  meta,
  meta_config,
  commit
)
  local sdrained_fluid = FluidTanks.drain_fluid(tank_pos, tank_face, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    local used_fluid = FluidMeta.fill_fluid(meta, meta_config.tank_name, sdrained_fluid,
                                            meta_config.bandwidth, meta_config.capacity, commit)
    if used_fluid and used_fluid.amount > 0 then
      local drained_fluid = FluidTanks.drain_fluid(tank_pos, tank_face, used_fluid, commit)
      return drained_fluid
    end
  end
  return nil
end

---
--- @spec transfer_from_tank_to_tank(
---   Vector3,
---   Direction.code,
---   FluidStack,
---   Vector3,
---   Direction.code,
---   Boolean
--- ): FluidStack
function FluidExchange.transfer_from_tank_to_tank(
  from_pos,
  from_face,
  fluid_stack,
  to_pos,
  to_face,
  commit
)
  -- the first drain is always a non-commit,
  -- this ensures that the fluid exists in the container in question
  local sdrained_fluid = FluidTanks.drain_fluid(from_pos, from_face, fluid_stack, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    -- now, we'll attempt to fill the tank with the given fluid, commit is used this time around
    local used_fluid = FluidTanks.fill_fluid(to_pos, to_face, sdrained_fluid, commit)
    if used_fluid and used_fluid.amount > 0 then
      -- Commit is used here as well
      local filled_fluid = FluidTanks.drain_fluid(from_pos, from_face, used_fluid, commit)
      return filled_fluid
    end
  end
  return nil
end

---
--- @since "2.7.0"
--- @spec transfer_from_meta_to_container(
---   meta: IMetaRef,
---   meta_config: FluidMetaConfig,
---   fluid_stack: FluidStack,
---   tank_pos: Vector3,
---   tank_face: Direction.code,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_meta_to_container(
  meta,
  meta_config,
  fluid_stack,
  item_stack,
  commit
)
  -- the first drain is always a non-commit,
  -- this ensures that the fluid exists in the container in question
  local sdrained_fluid = FluidMeta.drain_fluid(meta, meta_config.tank_name, fluid_stack,
                                               meta_config.bandwidth, meta_config.capacity, false)
  if sdrained_fluid and sdrained_fluid.amount > 0 then
    -- now, we'll attempt to fill the tank with the given fluid, commit is used this time around
    local used_fluid = FluidContainers.fill_fluid(item_stack, sdrained_fluid, commit)
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

---
---
--- @spec transfer_from_meta_to_meta(
---   from_meta: MetaRef,
---   from_meta_config: FluidMetaConfig,
---   fluid_stack: FluidStack,
---   to_meta: MetaRef,
---   to_meta_config: FluidMetaConfig,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_meta_to_meta(
  from_meta,
  from_meta_config,
  fluid_stack,
  to_meta,
  to_meta_config,
  commit
)
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
                                                  used_fluid,
                                                  from_meta_config.bandwidth,
                                                  from_meta_config.capacity,
                                                  commit)
      return drained_fluid
    end
  end
end

---
--- @spec transfer_from_meta_to_tank(
---   meta: IMetaRef,
---   meta_config: FluidMetaConfig,
---   fluid_stack: FluidStack,
---   tank_pos: Vector3,
---   tank_face: Direction.code,
---   commit: Boolean
--- ): FluidStack
function FluidExchange.transfer_from_meta_to_tank(
  meta,
  meta_config,
  fluid_stack,
  tank_pos,
  tank_face,
  commit
)
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

yatm_fluids.FluidExchange = FluidExchange
