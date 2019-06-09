local variants = {
  {"hazard", "Hazard"},
  {"coolant", "Coolant"},
  {"signal", "Signal"},
}

for _, variant_pair in ipairs(variants) do
  local variant_basename = variant_pair[1]
  local variant_name = variant_pair[2]

  local import_bus_yatm_network = {
    kind = "machine",
    groups = {
      reactor_part = 1,
      reactor_import_bus = 1,
    },
    states = {
      conflict = "yatm_reactors:import_bus_" .. variant_basename .. "_error",
      error = "yatm_reactors:import_bus_" .. variant_basename .. "_error",
      off = "yatm_reactors:import_bus_" .. variant_basename .. "_off",
      on = "yatm_reactors:import_bus_" .. variant_basename .. "_on",
    }
  }

  local groups = {cracky = 1}
  if variant_basename == "hazard" or variant_basename == "coolant" then
    groups.fluid_interface_in = 1
  elseif variant_basename == "signal" then
    groups.mesecon_interface_in = 1
  end

  yatm.devices.register_network_device("yatm_reactors:import_bus_" .. variant_basename .. "_off", {
    description = "Reactor Import Bus (" .. variant_name .. ")",
    groups = groups,
    drop = import_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_import_bus_front.off.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = import_bus_yatm_network,
  })

  yatm.devices.register_network_device("yatm_reactors:import_bus_" .. variant_basename .. "_error", {
    description = "Reactor Import Bus (" .. variant_name .. ")",
    groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
    drop = import_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_import_bus_front.error.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = import_bus_yatm_network,
  })

  yatm.devices.register_network_device("yatm_reactors:import_bus_" .. variant_basename .. "_on", {
    description = "Reactor Import Bus (" .. variant_name .. ")",
    groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
    drop = import_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_import_bus_front.on.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = import_bus_yatm_network,
  })
end
