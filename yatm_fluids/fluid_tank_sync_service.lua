local Directions = assert(foundation.com.Directions)
local Groups = assert(foundation.com.Groups)
local FluidTanks = assert(yatm_fluids.FluidTanks)
local FluidStack = assert(yatm_fluids.FluidStack)
local Vector3 = assert(foundation.com.Vector3)

local FluidTankSyncService = foundation.com.Class:extends("FluidTankSyncService")
do
  local ic = FluidTankSyncService.instance_class

  local function hash_column_position(pos)
    return (pos.z + 0x8000) * 0x100000000 + 0x8000 * 0x10000 + (pos.x + 0x8000)
  end

  --- @spec #initialize(): void
  function ic:initialize()
    ic._super.initialize(self)

    self.m_columns = {}
  end

  --- @spec #mark_for_update(pos: Vector3): void
  function ic:mark_for_update(pos)
    local id = hash_column_position(pos)
    local entry = self.m_columns[id]
    if not entry then
      entry = {}
      self.m_columns[id] = entry
    end

    entry[pos.y] = true
  end

  --- @spec #update(dtime: Float, trace: Trace)
  function ic:update(dtime, trace)
    if next(self.m_columns) then
      local columns = self.m_columns
      self.m_columns = {}
      local pos
      local node
      local nodedef

      local neighbour_y
      local neighbour_fill_dir
      local neighbour_offset
      local neighbour_pos = Vector3.new(0, 0, 0)
      local neighbour_node
      local neighbour_nodedef

      local min_y
      local max_y
      local seen
      local draining_stack
      local filled_stack
      for xy_hash,entries in pairs(columns) do
        pos = minetest.get_position_from_hash(xy_hash)
        seen = {}
        for y,_ in pairs(entries) do
          pos.y = y
          if not seen[pos.y] then
            while true do
              node = minetest.get_node_or_nil(pos)
              if not node then
                break
              end

              nodedef = minetest.registered_nodes[node.name]
              if not nodedef then
                break
              end

              if not Groups.has_group(nodedef, "fluid_tank") then
                break
              end

              seen[pos.y] = node

              pos.y = pos.y - 1
            end
            min_y = pos.y

            pos.y = y
            while true do
              node = minetest.get_node_or_nil(pos)
              if not node then
                break
              end

              nodedef = minetest.registered_nodes[node.name]
              if not nodedef then
                break
              end

              if not Groups.has_group(nodedef, "fluid_tank") then
                break
              end

              seen[pos.y] = node

              pos.y = pos.y + 1
            end
            max_y = pos.y

            pos.y = min_y
            neighbour_pos.x = pos.x
            neighbour_pos.z = pos.z
            while pos.y < max_y do
              neighbour_fill_dir = Directions.D_UP
              neighbour_y = -1

              draining_stack =
                FluidTanks.drain_fluid(
                  pos,
                  Directions.D_NONE,
                  FluidStack.new_wildcard(yatm_fluids.fluid_tank_fluid_interface._private.bandwidth),
                  false
                )

              if draining_stack and draining_stack.amount > 0 then
                if FluidStack.is_member_of_group(draining_stack, "gas") then
                  neighbour_fill_dir = Directions.D_DOWN
                  neighbour_y = 1
                end

                neighbour_pos.y = pos.y + neighbour_y
                neighbour_node = seen[neighbour_pos.y]
                if neighbour_node then
                  neighbour_nodedef = minetest.registered_nodes[neighbour_node.name]
                  if neighbour_nodedef and Groups.has_group(neighbour_nodedef, "fluid_tank") then
                    filled_stack =
                      FluidTanks.fill_fluid(
                        neighbour_pos,
                        neighbour_fill_dir,
                        draining_stack,
                        true
                      )

                    if filled_stack then
                      FluidTanks.drain_fluid(pos, Directions.D_NONE, filled_stack, true)
                    end
                  end
                end
              end

              pos.y = pos.y + 1
            end
          end
        end
      end
    end
  end
end

yatm_fluids.FluidTankSyncService = FluidTankSyncService
