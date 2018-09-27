local heater_yatm_network = {
  kind = "machine",
  groups = {machine = 1},
  states = {
    conflict = "yatm_machines:heater_error",
    error = "yatm_machines:heater_error",
    off = "yatm_machines:heater",
    on = "yatm_machines:heater_on",
  }
}

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
  groups = {cracky = 1},
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
})
