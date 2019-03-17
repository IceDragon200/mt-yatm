local variants = {
  {"hazard", "Hazard"},
  {"coolant", "Coolant"},
  {"signal", "Signal"},
}

for _, variant_pair in ipairs(variants) do
  local variant_basename = variant_pair[1]
  local variant_name = variant_pair[2]

  local export_bus_yatm_network = {
    kind = "machine",
    groups = {
      reactor_part = 1,
      reactor_export_bus = 1,
    },
    states = {
      conflict = "yatm_reactors:export_bus_" .. variant_basename .. "_error",
      error = "yatm_reactors:export_bus_" .. variant_basename .. "_error",
      off = "yatm_reactors:export_bus_" .. variant_basename .. "_off",
      on = "yatm_reactors:export_bus_" .. variant_basename .. "_on",
    }
  }

  local groups = {cracky = 1}
  if variant_basename == "hazard" or variant_basename == "coolant" then
    groups.fluid_interface_out = 1
  elseif variant_basename == "signal" then
    groups.mesecon_interface_out = 1
  end

  yatm.devices.register_network_device(export_bus_yatm_network.states.off, {
    description = "Reactor Export Bus (" .. variant_name .. ")",

    groups = groups,

    drop = export_bus_yatm_network.states.off,

    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_export_bus_front.off.png"
    },

    paramtype = "light",
    paramtype2 = "facedir",

    yatm_network = export_bus_yatm_network,
  })

  yatm.devices.register_network_device(export_bus_yatm_network.states.error, {
    description = "Reactor Export Bus (" .. variant_name .. ")",

    groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),

    drop = export_bus_yatm_network.states.off,

    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_export_bus_front.error.png"
    },

    paramtype = "light",
    paramtype2 = "facedir",

    yatm_network = export_bus_yatm_network,
  })

  yatm.devices.register_network_device(export_bus_yatm_network.states.on, {
    description = "Reactor Export Bus (" .. variant_name .. ")",

    groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),

    drop = export_bus_yatm_network.states.off,

    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant_basename .. "_export_bus_front.on.png"
    },

    paramtype = "light",
    paramtype2 = "facedir",

    yatm_network = export_bus_yatm_network,
  })
end
