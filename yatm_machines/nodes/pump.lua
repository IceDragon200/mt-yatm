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

function pump_yatm_network.update(pos, node)
  if node.name == "yatm_machines:pump_on" then
    local nodedef = minetest.registered_nodes[node.name]
    if nodedef then
      local new_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
      local target = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
      local target_node = minetest.get_node(target)
      local fluid_name = yatm_core.fluids.get_item_fluid(target_node.name)
      if fluid_name then
        local stack = yatm_core.fluid_tanks.fill(pos, new_dir, fluid_name, 1000, true)
        if stack and stack.amount > 0 then
          minetest.remove_node(target)
        end
      end

      local new_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_UP)
      local target = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_dir])
      local stack = yatm_core.fluid_tanks.drain(pos, new_dir, fluid_name, 1000, false)
      if stack and stack.amount > 0 then
        local target_dir = yatm_core.invert_dir(new_dir)
        local filled_stack = yatm_core.fluid_tanks.fill(target, target_dir, stack.name, stack.amount, true)
        if filled_stack then
          yatm_core.fluid_tanks.drain(pos, new_dir, filled_stack.name, filled_stack.amount, true)
        end
      end
    end
  end
end

local fluids_interface = yatm_core.new_simple_fluids_interface("tank", 4000)

local old_fill = fluids_interface.fill
function fluids_interface.fill(pos, dir, node, fluid_name, amount, commit)
  local pump_in_dir = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
  if dir == pump_in_dir then
    return old_fill(pos, dir, node, fluid_name, amount, commit)
  else
    print("Rejected fill request because it's the wrong direction", "expected", pump_in_dir, "got", dir)
    return nil
  end
end

yatm_machines.register_network_device("yatm_machines:pump_off", {
  description = "Pump",
  groups = {cracky = 1},
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
  yatm_network = pump_yatm_network,
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device("yatm_machines:pump_error", {
  description = "Pump",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  yatm_network = pump_yatm_network,
  fluids_interface = fluids_interface,
})

yatm_machines.register_network_device("yatm_machines:pump_on", {
  description = "Pump",
  groups = {cracky = 1, not_in_creative_inventory = 1},
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
  yatm_network = pump_yatm_network,
  fluids_interface = fluids_interface,
})
