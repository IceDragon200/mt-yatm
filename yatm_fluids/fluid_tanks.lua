--
-- Utility module for interacting with fluid tanks in the world.
--
local FluidStack = assert(yatm_fluids.FluidStack)

--- @namespace yatm_fluids.FluidTanks
local FluidTanks = {
  version = "1.2.0"
}

function FluidTanks.has_fluid_interface(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef then
    if nodedef.fluid_interface then
      return true
    end
    return nil, "no fluid_interface"
  end
  return nil, "no nodedef"
end

--- @since "1.2.0"
function FluidTanks.get_fluid_interface(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]

  if nodedef and nodedef.fluid_interface then
    return nodedef.fluid_interface
  end
  return nil, "no fluid interface"
end

--- @spec get_capacity(pos: Vector3, dir: Direction): (Integer, nil) | (nil, String)
function FluidTanks.get_capacity(pos, dir)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local fi = nodedef.fluid_interface
    if fi and fi.get_capacity then
      return nodedef.fluid_interface:get_capacity(pos, dir)
    else
      return "no fluid_interface:get_capacity function"
    end
    return "no fluid_interface"
  end
  return nil, "no nodedef"
end

--- @spec get_fluid(pos: Vector3, dir: Direction): (FluidStack, nil) | (nil, String)
function FluidTanks.get_fluid(pos, dir)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
    local fi = nodedef.fluid_interface
    if fi and fi.get then
      return nodedef.fluid_interface:get(pos, dir)
    end
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
    local fi = nodedef.fluid_interface
    if fi and fi.replace then
      return fi:replace(pos, dir, fluid_stack, commit)
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
    local fi = nodedef.fluid_interface
    if fi and fi.drain then
      return fi:drain(pos, dir, fluid_stack, commit)
    end
  end

  return nil, "fluid_interface unavailable"
end

--- Attempts to fill the FluidTank at specified location.
--- This function returns the amount of fluid actually used.
--- If the tank rejected the fluid or any other error occured nil will be returned instead.
---
--- @spec fill_fluid(
---   pos: Vector3,
---   dir: foundation.com.Direction,
---   fluid_stack: FluidStack,
---   commit: Boolean
--- ): (FluidStack, nil) | (nil, error: String)
function FluidTanks.fill_fluid(pos, dir, fluid_stack, commit)
  if type(dir) ~= "number" then
    error("expected a number got:" .. type(dir))
  end

  assert(fluid_stack, "expected a FluidStack")

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

  local fi = nodedef.fluid_interface
  if not fi then
    return nil, "fluid_interface unavailable"
  end

  if not fi.fill then
    return nil, "fluid_interface does not have fill function"
  end

  return fi:fill(pos, dir, fluid_stack, commit)
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
