--
-- Utility module for interacting with fluid tanks in the world.
--
local FluidStack = assert(yatm_fluids.FluidStack)

local FluidTanks = {
  version = "1.2.0"
}

function FluidTanks.has_fluid_interface(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef and nodedef.fluid_interface then
    return true
  end
  return nil, "no nodedef, or fluid_interface"
end

--@since "1.2.0"
function FluidTanks.get_fluid_interface(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef and nodedef.fluid_interface then
    return nodedef.fluid_interface
  end
  return nil, "no fluid interface"
end

function FluidTanks.get_capacity(pos, dir)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.get_capacity then
    return nodedef.fluid_interface:get_capacity(pos, dir)
  end
  return nil, "no nodedef, fluid_interface or get_capacity function"
end

function FluidTanks.get_fluid(pos, dir)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.get then
    return nodedef.fluid_interface:get(pos, dir)
  end
  return nil, "fluid_interface unavailable"
end

function FluidTanks.replace_fluid(pos, dir, fluid_stack, commit)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end

  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef and nodedef.groups.fluid_interface_in then
    if nodedef.fluid_interface and nodedef.fluid_interface.replace then
      return nodedef.fluid_interface:replace(pos, dir, fluid_stack, commit)
    end
  end

  return nil, "fluid_interface unavailable"
end

function FluidTanks.drain_fluid(pos, dir, fluid_stack, commit)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end

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

  return nil, "fluid_interface unavailable"
end

function FluidTanks.fill_fluid(pos, dir, fluid_stack, commit)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end

  if fluid_stack.amount <= 0 then
    return nil, "fluid stack was empty"
  end

  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if not nodedef then
    return nil, "node definition not found"
  end

  if not nodedef.groups.fluid_interface_in then
    return nil, "fluid_interface does not support input"
  end

  if not nodedef.fluid_interface then
    return nil, "fluid_interface unavailable"
  end

  if not nodedef.fluid_interface.fill then
    return nil, "fluid_interface does not have fill function"
  end

  return nodedef.fluid_interface:fill(pos, dir, fluid_stack, commit)
end

function FluidTanks.trigger_on_fluid_changed(pos, dir, fluid_stack)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end

  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluid_interface and nodedef.fluid_interface.on_fluid_changed then
    return nodedef.fluid_interface:on_fluid_changed(pos, dir, fluid_stack)
  end
  return nil, "fluid_interface unavailable"
end

yatm_fluids.FluidTanks = FluidTanks
