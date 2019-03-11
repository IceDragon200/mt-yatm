--[[
Utility module for interacting with fluid tanks in the world.
]]
local FluidStack = assert(yatm_fluids.FluidStack)

local FluidTanks = {
}

function FluidTanks.get(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.get then
    return nodedef.fluid_interface:get(pos, dir)
  end
  return nil
end

function FluidTanks.replace(pos, dir, fluid_stack, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.replace then
    return nodedef.fluid_interface:replace(pos, dir, fluid_stack, commit)
  end
  return nil
end

function FluidTanks.drain(pos, dir, fluid_stack, commit)
  if fluid_stack.amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.drain then
    return nodedef.fluid_interface:drain(pos, dir, fluid_stack, commit)
  end
  return nil
end

function FluidTanks.fill(pos, dir, fluid_stack, commit)
  if fluid_stack.amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.fill then
    return nodedef.fluid_interface:fill(pos, dir, fluid_stack, commit)
  end
  return nil
end

function FluidTanks.trigger_on_fluid_changed(pos, dir, fluid_stack)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.on_fluid_changed then
    return nodedef.fluid_interface:on_fluid_changed(pos, dir, fluid_stack)
  end
  return nil
end

yatm_fluids.FluidTanks = FluidTanks
