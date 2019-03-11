local FluidStack = assert(yatm_core.FluidStack)

local pump_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:pump_error",
    error = "yatm_machines:pump_error",
    off = "yatm_machines:pump_off",
    on = "yatm_machines:pump_on",
  },
  passive_energy_lost = 0
}

local fluids_interface = yatm_core.new_simple_fluids_interface("tank", 16000)

function pump_yatm_network.refresh_infotext(pos, node, meta, event)
  local new_node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[new_node.name]
  local state = nodedef.yatm_network.state
  local network_id = yatm_core.Network.get_meta_network_id(meta)
  local fluid_stack = yatm_core.fluids.get_fluid(meta, fluids_interface.tank_name)
  meta:set_string("infotext",
    "Network ID " .. dump(network_id) .. " " .. state .. "\n" ..
    "Tank " .. yatm_core.FluidStack.to_string(fluid_stack, fluids_interface.capacity)
  )
end

function pump_yatm_network.update(pos, node, _ot)
  local pump_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  local target_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[pump_dir])
  local target_node = minetest.get_node(target_pos)
  local fluid_name = yatm_core.fluids.get_item_fluid_name(target_node.name)

  if fluid_name then
    local used_stack = yatm_core.fluid_tanks.fill(pos, pump_dir, FluidStack.new(fluid_name, 1000), true)
    if used_stack and used_stack.amount > 0 then
      minetest.remove_node(target_pos)
    end
  else
    local inverted_dir = yatm_core.invert_dir(pump_dir)
    local drained_stack = yatm_core.fluid_tanks.drain(target_pos, inverted_dir, FluidStack.new_wildcard(1000), false)
    if drained_stack and drained_stack.amount > 0 then
      local existing = yatm_core.fluid_tanks.get(pos, pump_dir)
      local filled_stack = yatm_core.fluid_tanks.fill(pos, pump_dir, drained_stack, true)

      if filled_stack and filled_stack.amount > 0 then
        yatm_core.fluid_tanks.drain(target_pos,
          inverted_dir,
          FluidStack.set_amount(drained_stack, filled_stack.amount), true)
      end
    end
  end

  local meta = minetest.get_meta(pos)
  do
    local new_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
    local target_pos = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
    local stack = yatm_core.fluids.drain_fluid(meta,
      "tank",
      FluidStack.new_wildcard(1000),
      fluids_interface.capacity, fluids_interface.capacity, false)
    if stack and stack.amount > 0 then
      local target_dir = yatm_core.invert_dir(new_dir)
      local filled_stack = FluidStack.presence(yatm_core.fluid_tanks.fill(target_pos, target_dir, stack, true))
      if filled_stack then
        yatm_core.fluids.drain_fluid(meta,
          "tank",
          filled_stack,
          fluids_interface.capacity, fluids_interface.capacity, true)
      end
    end

    print(minetest.pos_to_string(pos), yatm_core.fluids.inspect(meta, "tank"))
  end
end

local old_fill = fluids_interface.fill
function fluids_interface:fill(pos, dir, fluid_stack, commit)
  local node = minetest.get_node(pos)
  local pump_in_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  if dir == pump_in_dir then
    return old_fill(self, pos, dir, fluid_stack, commit)
  else
    --print("Rejected fill request because it's the wrong direction", "expected", pump_in_dir, "got", dir)
    return nil
  end
end

yatm_machines.register_network_device(pump_yatm_network.states.off, {
  description = "Pump",
  groups = {cracky = 1},
  drop = pump_yatm_network.states.off,
  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.off.png",
    "yatm_pump_side.off.png^[transformFX",
    "yatm_pump_back.off.png",
    "yatm_pump_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(pump_yatm_network, {state = "off"}),
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device(pump_yatm_network.states.error, {
  description = "Pump",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = pump_yatm_network.states.off,
  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.error.png",
    "yatm_pump_side.error.png^[transformFX",
    "yatm_pump_back.error.png",
    "yatm_pump_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(pump_yatm_network, {state = "error"}),
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device(pump_yatm_network.states.on, {
  description = "Pump",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = pump_yatm_network.states.off,
  tiles = {
    "yatm_pump_top.png",
    "yatm_pump_bottom.png",
    "yatm_pump_side.on.png",
    "yatm_pump_side.on.png^[transformFX",
    "yatm_pump_back.on.png",
    "yatm_pump_front.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = yatm_core.table_merge(pump_yatm_network, {state = "on"}),
  fluids_interface = fluids_interface,
})
