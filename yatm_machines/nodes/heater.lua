local heater_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:heater_error",
    error = "yatm_machines:heater_error",
    off = "yatm_machines:heater",
    on = "yatm_machines:heater_on",
  },
  passive_energy_lost = 100,
}

function heater_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

yatm_machines.register_network_device("yatm_machines:heater", {
  description = "Heater",
  groups = {cracky = 1},
  tiles = {
    "yatm_heater_top.off.png",
    "yatm_heater_bottom.png",
    "yatm_heater_side.off.png",
    "yatm_heater_side.off.png^[transformFX",
    "yatm_heater_back.off.png",
    "yatm_heater_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = heater_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:heater_error", {
  description = "Heater",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_heater_top.error.png",
    "yatm_heater_bottom.png",
    "yatm_heater_side.error.png",
    "yatm_heater_side.error.png^[transformFX",
    "yatm_heater_back.error.png",
    "yatm_heater_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = heater_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:heater_on", {
  description = "Heater",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_heater_top.on.png",
    "yatm_heater_bottom.png",
    "yatm_heater_side.on.png",
    "yatm_heater_side.on.png^[transformFX",
    "yatm_heater_back.on.png",
    "yatm_heater_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = heater_yatm_network,
  sunlight_propagates = true,
  light_source = default.LIGHT_MAX,
})
