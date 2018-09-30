local boiler_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:boiler_error",
    error = "yatm_machines:boiler_error",
    off = "yatm_machines:boiler_off",
    on = "yatm_machines:boiler_on",
  },
  passive_energy_consume = 0
}

function boiler_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm_machines.register_network_device("yatm_machines:boiler_off", {
  description = "Pump",
  groups = {cracky = 1},
  tiles = {
    "yatm_boiler_top.off.png",
    "yatm_boiler_bottom.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png",
    "yatm_boiler_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = boiler_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:boiler_error", {
  description = "Pump",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_boiler_top.error.png",
    "yatm_boiler_bottom.error.png",
    "yatm_boiler_side.error.png",
    "yatm_boiler_side.error.png",
    "yatm_boiler_side.error.png",
    "yatm_boiler_side.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = boiler_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:boiler_on", {
  description = "Pump",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_boiler_top.on.png",
    "yatm_boiler_bottom.on.png",
    "yatm_boiler_side.on.png",
    "yatm_boiler_side.on.png",
    "yatm_boiler_side.on.png",
    "yatm_boiler_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = boiler_yatm_network,
})
