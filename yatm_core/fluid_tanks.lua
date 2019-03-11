local FluidStack = yatm_core.FluidStack

local fluid_tanks = {
  fluid_name_to_tank_name = {}
}

function fluid_tanks.get(pos, dir)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluids_interface and nodedef.fluids_interface.get then
    return nodedef.fluids_interface:get(pos, dir)
  end
  return nil
end

function fluid_tanks.replace(pos, dir, fluid_stack, commit)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluids_interface and nodedef.fluids_interface.replace then
    return nodedef.fluids_interface:replace(pos, dir, fluid_stack, commit)
  end
  return nil
end

function fluid_tanks.drain(pos, dir, fluid_stack, commit)
  if fluid_stack.amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluids_interface and nodedef.fluids_interface.drain then
    return nodedef.fluids_interface:drain(pos, dir, fluid_stack, commit)
  end
  return nil
end

function fluid_tanks.fill(pos, dir, fluid_stack, commit)
  if fluid_stack.amount <= 0 then
    return nil
  end
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluids_interface and nodedef.fluids_interface.fill then
    return nodedef.fluids_interface:fill(pos, dir, fluid_stack, commit)
  end
  return nil
end

function fluid_tanks.trigger_on_fluid_changed(pos, dir, fluid_stack)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef and nodedef.fluids_interface and nodedef.fluids_interface.on_fluid_changed then
    return nodedef.fluids_interface:on_fluid_changed(pos, dir, fluid_stack)
  end
  return nil
end

yatm_core.fluid_tanks = fluid_tanks
