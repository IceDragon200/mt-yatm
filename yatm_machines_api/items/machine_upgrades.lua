local mod = assert(yatm_machines_api)

--
-- Amplify
--
mod:register_craftitem("machine_upgrade_amplify_cooling", {
  description = mod.S("UPGRADE Amplify Cooling"),

  groups = {
    machine_upgrade = 1,
    machine_amplify_upgrade = 1,
    amplify_cooling = 1,
  },

  inventory_image = "yatm_machine_upgrade.amplify.cooling.png",
})

mod:register_craftitem("machine_upgrade_amplify_heating", {
  description = mod.S("UPGRADE Amplify Heating"),

  groups = {
    machine_upgrade = 1,
    machine_amplify_upgrade = 1,
    amplify_heating = 1,
  },

  inventory_image = "yatm_machine_upgrade.amplify.heating.png",
})

mod:register_craftitem("machine_upgrade_amplify_nuclear", {
  description = mod.S("UPGRADE Amplify Nuclear"),

  groups = {
    machine_upgrade = 1,
    machine_amplify_upgrade = 1,
    amplify_nuclear = 1,
  },

  inventory_image = "yatm_machine_upgrade.amplify.nuclear.png",
})

--
-- Coil
--
mod:register_craftitem("machine_upgrade_coil_cooling", {
  description = mod.S("UPGRADE Amplify Cooling"),

  groups = {
    machine_upgrade = 1,
    machine_coil_upgrade = 1,
    coil_cooling = 1,
  },

  inventory_image = "yatm_machine_upgrade.coil.cooling.png",
})

mod:register_craftitem("machine_upgrade_coil_heating", {
  description = mod.S("UPGRADE Amplify Heating"),

  groups = {
    machine_upgrade = 1,
    machine_coil_upgrade = 1,
    coil_heating = 1,
  },

  inventory_image = "yatm_machine_upgrade.coil.heating.png",
})

mod:register_craftitem("machine_upgrade_coil_nuclear", {
  description = mod.S("UPGRADE Amplify Nuclear"),

  groups = {
    machine_upgrade = 1,
    machine_coil_upgrade = 1,
    coil_nuclear = 1,
  },

  inventory_image = "yatm_machine_upgrade.coil.nuclear.png",
})

--
-- Auto-Eject
--
mod:register_craftitem("machine_upgrade_auto_eject_item", {
  description = mod.S("BEHAVIOUR Item Auto-Eject"),

  groups = {
    machine_upgrade = 1,
    machine_behaviour_upgrade = 1,
    behaviour_item_auto_eject = 1,
  },

  inventory_image = "yatm_machine_upgrade.auto_eject.items.png",
})

mod:register_craftitem("machine_upgrade_auto_eject_fluid", {
  description = mod.S("BEHAVIOUR Fluid Auto-Eject"),

  groups = {
    machine_upgrade = 1,
    machine_behaviour_upgrade = 1,
    behaviour_fluid_auto_eject = 1,
  },

  inventory_image = "yatm_machine_upgrade.auto_eject.fluids.png",
})

--
--
--
mod:register_craftitem("machine_upgrade_efficiency", {
  description = mod.S("UPGRADE Efficiency"),

  groups = {
    machine_upgrade = 1,
    machine_efficiency_upgrade = 1,
  },

  inventory_image = "yatm_machine_upgrade.efficiency.png",
})

mod:register_craftitem("machine_upgrade_energy", {
  description = mod.S("UPGRADE Energy"),

  groups = {
    machine_upgrade = 1,
    machine_energy_upgrade = 1,
  },

  inventory_image = "yatm_machine_upgrade.energy.png",
})

mod:register_craftitem("machine_upgrade_blank", {
  description = mod.S("UPGRADE BLANK"),

  groups = {
    machine_upgrade_blank = 1,
  },

  inventory_image = "yatm_machine_upgrade.blank.png",
})
