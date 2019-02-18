for _, variant in ipairs({"hazard", "coolant", "signal"}) do
  local import_bus_yatm_network = {
    kind = "machine",
    groups = {
      reactor = 1,
      reactor_import_bus = 1,
    },
    states = {
      conflict = "yatm_reactors:import_bus_" .. variant .. "_error",
      error = "yatm_reactors:import_bus_" .. variant .. "_error",
      off = "yatm_reactors:import_bus_" .. variant .. "_off",
      on = "yatm_reactors:import_bus_" .. variant .. "_on",
    }
  }

  yatm_machines.register_network_device("yatm_reactors:import_bus_" .. variant .. "_off", {
    description = "Reactor Import Bus (" .. variant .. ")",
    groups = {cracky = 1},
    drop = import_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant .. "_import_bus_front.off.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = import_bus_yatm_network,
  })

  yatm_machines.register_network_device("yatm_reactors:import_bus_" .. variant .. "_error", {
    description = "Reactor Import Bus (" .. variant .. ")",
    groups = {cracky = 1, not_in_creative_inventory = 1},
    drop = import_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant .. "_import_bus_front.error.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = import_bus_yatm_network,
  })

  yatm_machines.register_network_device("yatm_reactors:import_bus_" .. variant .. "_on", {
    description = "Reactor Import Bus (" .. variant .. ")",
    groups = {cracky = 1, not_in_creative_inventory = 1},
    drop = import_bus_yatm_network.states.off,
    tiles = {
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_" .. variant .. "_import_bus_front.on.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = import_bus_yatm_network,
  })
end
