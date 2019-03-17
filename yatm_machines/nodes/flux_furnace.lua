local flux_furnace_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:flux_furnace_error",
    error = "yatm_machines:flux_furnace_error",
    off = "yatm_machines:flux_furnace_off",
    on = "yatm_machines:flux_furnace_on",
  },
  passive_energy_lost = 20,
}

function flux_furnace_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
}

yatm.devices.register_network_device("yatm_machines:flux_furnace_off", {
  description = "Flux Furnace",
  groups = groups,
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

yatm.devices.register_network_device("yatm_machines:flux_furnace_error", {
  description = "Flux Furnace",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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

yatm.devices.register_network_device("yatm_machines:flux_furnace_on", {
  description = "Flux Furnace",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
