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
  passive_energy_consume = 0
}

function pump_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
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
})

minetest.register_abm({
  label = "YATM Pumping water",
  nodenames = {"yatm_machines:pump", "yatm_machines:pump_on"},
  neighbors = {"group:water"},
  interval = 1.0,
  chance = 1,
  action = function (pos, node)
    local new_face = yatm_core.facedir_to_face(node.param2, yatm_core.D_DOWN)
    local target = vector.add(pos, yatm_core.DIR6_TO_VEC3[new_face])
    local target_node = minetest.get_node(target)
    local target_nodedef = minetest.registered_nodes[target_node.name]
    if target_nodedef.groups.water then
      print("Pumping " .. target_node.name .. "!")
      minetest.remove_node(target)
    end
  end
})
