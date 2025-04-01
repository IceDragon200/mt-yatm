--[[

  Upgrades implementations

]]
local mod = assert(yatm_machines_api)

yatm.devices.upgrades.register_upgrade("amplify_cooling", {
  description = mod.S("AMPLIFY Cooling"),

  item = mod:make_name("machine_upgrade_amplify_cooling"),

  stats = {
    cooling_rate = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.01
    end,
  }
})

yatm.devices.upgrades.register_upgrade("amplify_heating", {
  description = mod.S("AMPLIFY Heating"),

  item = mod:make_name("machine_upgrade_amplify_heating"),

  stats = {
    heating_rate = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.01
    end,
  }
})

yatm.devices.upgrades.register_upgrade("amplify_nuclear", {
  description = mod.S("AMPLIFY Nuclear"),

  item = mod:make_name("machine_upgrade_amplify_nuclear"),

  stats = {
    radiation_rate = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.01
    end,
  }
})

yatm.devices.upgrades.register_upgrade("coil_cooling", {
  description = mod.S("COIL Cooling"),

  item = mod:make_name("machine_upgrade_coil_cooling"),

  stats = {
    cooling_emission = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.1
    end,
  }
})

yatm.devices.upgrades.register_upgrade("coil_heating", {
  description = mod.S("COIL Heating"),

  item = mod:make_name("machine_upgrade_coil_heating"),

  stats = {
    heating_emission = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.1
    end,
  }
})

yatm.devices.upgrades.register_upgrade("coil_nuclear", {
  description = mod.S("COIL Nuclear"),

  item = mod:make_name("machine_upgrade_coil_nuclear"),

  stats = {
    radiation_emission = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.1
    end,
  }
})

yatm.devices.upgrades.register_upgrade("auto_eject_items", {
  description = mod.S("Auto-Eject Items"),

  item = mod:make_name("machine_upgrade_auto_eject_item"),

  behaviour_id = "item_auto_eject",
})

yatm.devices.upgrades.register_upgrade("auto_eject_fluids", {
  description = mod.S("Auto-Eject Fluids"),

  item = mod:make_name("machine_upgrade_auto_eject_fluid"),

  behaviour_id = "fluid_auto_eject",
})

yatm.devices.upgrades.register_upgrade("efficiency", {
  description = mod.S("Efficiency"),

  item = mod:make_name("machine_upgrade_efficiency"),

  stats = {
    work_rate = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 0.01
    end,

    energy_rate = function (upgrade, pos, node, meta, base)
      return base - upgrade.count * 0.01
    end,
  }
})

yatm.devices.upgrades.register_upgrade("energy", {
  description = mod.S("Efficiency"),

  item = mod:make_name("machine_upgrade_energy"),

  stats = {
    energy_capacity = function (upgrade, pos, node, meta, base)
      return base + upgrade.count * 100
    end,
  }
})
