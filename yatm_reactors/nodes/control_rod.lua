local control_rod_open_yatm_network = {
  kind = "machine",
  groups = {
    reactor = 1,
    reactor_control_rod = 1,
    reactor_control_rod_open = 1,
  },
  states = {
    conflict = "yatm_reactors:control_rod_open",
    error = "yatm_reactors:control_rod_open",
    off = "yatm_reactors:control_rod_open",
    on = "yatm_reactors:control_rod_open",
  }
}

yatm_machines.register_network_device("yatm_reactors:control_rod_open", {
  description = "Control Rod (Unoccupied)",
  groups = {cracky = 1},
  drop = "yatm_reactors:control_rod_open",
  tiles = {
    "yatm_reactor_control_rod.open.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png^[transformFX",
    "yatm_reactor_casing.plain.png",
    "yatm_reactor_casing.plain.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = control_rod_open_yatm_network,
})

for _, variant in ipairs({"uranium", "plutonium", "radium"}) do
  local control_rod_yatm_network = {
    kind = "machine",
    groups = {
      reactor = 1,
      reactor_control_rod = 1,
    },
    states = {
      conflict = "yatm_reactors:control_rod_close_" .. variant .. "_error",
      error = "yatm_reactors:control_rod_close_" .. variant .. "_error",
      off = "yatm_reactors:control_rod_close_" .. variant .. "_off",
      on = "yatm_reactors:control_rod_close_" .. variant .. "_on",
    }
  }

  yatm_machines.register_network_device(control_rod_yatm_network.states.off, {
    description = "Reactor Control Rod (" .. variant .. ")",
    groups = {cracky = 1},
    drop = control_rod_yatm_network.states.off,
    tiles = {
      "yatm_reactor_control_rod.close." .. variant .. ".png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = control_rod_yatm_network,
  })

  yatm_machines.register_network_device(control_rod_yatm_network.states.error, {
    description = "Reactor Control Rod (" .. variant .. ")",
    groups = {cracky = 1, not_in_creative_inventory = 1},
    drop = control_rod_yatm_network.states.off,
    tiles = {
      "yatm_reactor_control_rod.close." .. variant .. ".png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = control_rod_yatm_network,
  })

  yatm_machines.register_network_device(control_rod_yatm_network.states.on, {
    description = "Reactor Control Rod (" .. variant .. ")",
    groups = {cracky = 1, not_in_creative_inventory = 1},
    drop = control_rod_yatm_network.states.off,
    tiles = {
      "yatm_reactor_control_rod.close." .. variant .. ".png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png^[transformFX",
      "yatm_reactor_casing.plain.png",
      "yatm_reactor_casing.plain.png",
    },
    paramtype = "light",
    paramtype2 = "facedir",
    yatm_network = control_rod_yatm_network,
  })
end
