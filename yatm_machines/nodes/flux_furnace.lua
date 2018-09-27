local flux_furnace_yatm_network = {
  kind = "machine",
  groups = {machine = 1},
  states = {
    conflict = "yatm_machines:flux_furnace_error",
    error = "yatm_machines:flux_furnace_error",
    off = "yatm_machines:flux_furnace_off",
    on = "yatm_machines:flux_furnace_on",
  }
}

yatm_machines.register_network_device("yatm_machines:flux_furnace_off", {
  description = "Flux Furnace",
  groups = {cracky = 1},
  tiles = {
    "yatm_flux_furnace_top.off.png",
    "yatm_flux_furnace_bottom.png",
    "yatm_flux_furnace_side.off.png",
    "yatm_flux_furnace_side.off.png^[transformFX",
    "yatm_flux_furnace_back.png",
    "yatm_flux_furnace_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = flux_furnace_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:flux_furnace_error", {
  description = "Flux Furnace",
  groups = {cracky = 1},
  tiles = {
    "yatm_flux_furnace_top.error.png",
    "yatm_flux_furnace_bottom.png",
    "yatm_flux_furnace_side.error.png",
    "yatm_flux_furnace_side.error.png^[transformFX",
    "yatm_flux_furnace_back.png",
    "yatm_flux_furnace_front.error.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = flux_furnace_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:flux_furnace_on", {
  description = "Flux Furnace",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_flux_furnace_top.on.png",
    "yatm_flux_furnace_bottom.png",
    "yatm_flux_furnace_side.on.png",
    "yatm_flux_furnace_side.on.png^[transformFX",
    "yatm_flux_furnace_back.png",
    "yatm_flux_furnace_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = flux_furnace_yatm_network,
})
