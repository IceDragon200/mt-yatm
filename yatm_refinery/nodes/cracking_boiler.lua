local groups = {cracky = 1, fluid_interface_in = 1, fluid_interface_out = 1}

yatm.devices.register_network_device("yatm_refinery:cracking_boiler_off", {
  groups = yatm_core.table_merge(groups, {}),
})

yatm.devices.register_network_device("yatm_refinery:cracking_boiler_error", {
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
})

yatm.devices.register_network_device("yatm_refinery:cracking_boiler_on", {
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
})

