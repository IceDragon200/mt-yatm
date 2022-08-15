local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)
local FluidTanks = assert(yatm.fluids.FluidTanks)
local FluidStack = assert(yatm.fluids.FluidStack)

local function fluid_tank_drain_sync(pos, node)
  local draining_stack =
    FluidTanks.drain_fluid(
      pos,
      Directions.D_NONE,
      FluidStack.new_wildcard(yatm_fluids.fluid_tank_fluid_interface._private.bandwidth),
      false
    )

  if draining_stack and draining_stack.amount > 0 then
    -- by default, fluids in tanks will fall down
    local adjacent_direction = Directions.D_DOWN

    if FluidStack.is_member_of_group(draining_stack, "gas") then
      -- however gases will float up
      adjacent_direction = Directions.D_UP
    end

    local adjacent_offset = Directions.DIR6_TO_VEC3[adjacent_direction]
    local adjacent_pos = vector.add(pos, adjacent_offset)
    local adjacent_node = minetest.get_node_or_nil(adjacent_pos)

    if adjacent_node then
      local adjacent_nodedef = minetest.registered_nodes[adjacent_node.name]

      if adjacent_nodedef and Groups.has_group(adjacent_nodedef, "fluid_tank") then
        -- only fill if the adjacent node was some kind of fluid_tank
        local inv_dir = Directions.invert_dir(adjacent_direction)
        local filled_stack = FluidTanks.fill_fluid(adjacent_pos, inv_dir, draining_stack, true)

        if filled_stack and filled_stack.amount > 0 then
          local used_stack = FluidTanks.drain_fluid(pos, Directions.D_NONE, filled_stack, true)
        end
      end
    end
  end
end

local function fluid_tank_drain_sync_2(pos, node)
  --
  local draining_stack = FluidTanks.drain_fluid(pos, Directions.D_NONE,
    FluidStack.new_wildcard(yatm_fluids.fluid_tank_fluid_interface._private.bandwidth), false)

  if draining_stack and draining_stack.amount > 0 then
    -- First up, drain down. yep, drain DOWN.
    -- Down has the usual behaviour, just try to fill whatever is down there.
    local below_pos = vector.add(pos, Directions.V3_DOWN)
    local filled_stack = FluidTanks.fill_fluid(below_pos, Directions.D_UP, draining_stack, true)

    if filled_stack and filled_stack.amount > 0 then
      local used_stack = FluidTanks.drain_fluid(pos, Directions.D_NONE, filled_stack, true)
      draining_stack.amount = draining_stack.amount - used_stack.amount
    end

    local item_has_group = Groups.item_has_group
    -- Do we have anything left?
    while draining_stack and draining_stack.amount > 0 do
      local touched_any = false

      local lowest_tank

      for dir, vpos in pairs(Directions.DIR4_TO_VEC3) do
        local current_fluid = FluidTanks.get_fluid(pos, Directions.D_NONE)

        local npos = vector.add(pos, vpos)
        local nnode = minetest.get_node(npos)

        if item_has_group(nnode.name, "fluid_tank") then
          local other_fluid = FluidTanks.get_fluid(npos, Directions.D_NONE)

          if FluidStack.same_fluid_or_replacable_by(other_fluid, current_fluid) then
            if not other_fluid or current_fluid.amount > other_fluid.amount then
              if lowest_tank then
                if not other_fluid or lowest_tank.amount > other_fluid.amount then
                  lowest_tank = {amount = other_fluid.amount, pos = npos, dir = dir}
                end
              else
                lowest_tank = {
                  amount = (other_fluid and other_fluid.amount) or 0,
                  pos = npos,
                  dir = dir
                }
              end
            end
          end
        end
      end

      if lowest_tank then
        local npos = lowest_tank.pos
        local ndir = assert(lowest_tank.dir)

        local low_filled_stack =
          FluidTanks.fill_fluid(npos, Directions.invert_dir(ndir), draining_stack, true)

        if low_filled_stack and low_filled_stack.amount > 0 then
          local used_stack = FluidTanks.drain_fluid(npos, Directions.D_NONE, low_filled_stack, true)
          draining_stack.amount = draining_stack.amount - used_stack.amount
        else
          break
        end
      else
        break
      end
    end
  end
end

minetest.register_abm({
  label = "yatm_fluids:fluid_tank_sync",

  nodenames = {
    "group:filled_fluid_tank",
  },

  interval = 0,
  chance = 1,

  action = fluid_tank_drain_sync,
})
