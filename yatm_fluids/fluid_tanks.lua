--
-- Utility module for interacting with fluid tanks in the world.
--
local FluidStack = assert(yatm_fluids.FluidStack)

local FluidTanks = {
}

function FluidTanks.get_capacity(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.get_capacity then
    return nodedef.fluid_interface:get_capacity(pos, dir)
  end
  return nil, "no nodedef, fluid_interface or get_capacity function"
end

function FluidTanks.get_fluid(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.get then
    return nodedef.fluid_interface:get(pos, dir)
  end
  return nil
end

function FluidTanks.replace_fluid(pos, dir, fluid_stack, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.groups.fluid_interface_in then
    if nodedef.fluid_interface and nodedef.fluid_interface.replace then
      return nodedef.fluid_interface:replace(pos, dir, fluid_stack, commit)
    end
  end
  return nil
end

function FluidTanks.drain_fluid(pos, dir, fluid_stack, commit)
  if fluid_stack.amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.groups.fluid_interface_out then
    if nodedef.fluid_interface and nodedef.fluid_interface.drain then
      return nodedef.fluid_interface:drain(pos, dir, fluid_stack, commit)
    end
  end
  return nil
end

function FluidTanks.fill_fluid(pos, dir, fluid_stack, commit)
  if fluid_stack.amount <= 0 then
    return nil, "fluid stack was empty"
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.groups.fluid_interface_in then
    if nodedef.fluid_interface and nodedef.fluid_interface.fill then
      return nodedef.fluid_interface:fill(pos, dir, fluid_stack, commit)
    else
      return nil, "no fluid_interface or no fluid_interface.fill"
    end
  end
  return nil, "no nodedef or no fluid_interface_in"
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
