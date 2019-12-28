-- The Shell of the Missile, this is just the body of the missile
-- Individual warheads have to be attached
minetest.register_craftitem("yatm_armoury_icbm:icbm_shell", {
  description = "ICBM Shell",

  groups = {
    icbm_shell = 1,
  },

  inventory_image = "yatm_icbm_shell.png",
})

--
-- Warheads
--

-- Nuclear Warhead, deals a lot of damage on impact, but also causes radiation damage
-- rendering the area radioactive for a period
minetest.register_craftitem("yatm_armoury_icbm:icbm_nuclear_warhead", {
  description = "ICBM Nuclear Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_nuclear_warhead = 1,
  },

  icbm_warhead_type = "nuclear",

  inventory_image = "yatm_icbm_nuclear_warhead.png",
})

-- Load any fluid into the warhead, when detonated it will cause an associated effect.
--
minetest.register_craftitem("yatm_armoury_icbm:icbm_chemical_warhead", {
  description = "ICBM Chemical Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_chemical_warhead = 1,
  },

  icbm_warhead_type = "chemical",

  inventory_image = "yatm_icbm_chemical_warhead.png",
})


-- Sets fire to the area when detonated
minetest.register_craftitem("yatm_armoury_icbm:icbm_incendiary_warhead", {
  description = "ICBM Incendiary Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_incendiary_warhead = 1,
  },

  icbm_warhead_type = "incendiary",

  inventory_image = "yatm_icbm_incendiary_warhead.png",
})

-- Explosive, deals explosive damage
minetest.register_craftitem("yatm_armoury_icbm:icbm_explosive_warhead", {
  description = "ICBM Explosive Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_explosive_warhead = 1,
  },

  icbm_warhead_type = "explosive",

  inventory_image = "yatm_icbm_explosive_warhead.png",
})

-- High-Explosive, deals explosive damage
minetest.register_craftitem("yatm_armoury_icbm:icbm_he_warhead", {
  description = "ICBM HE Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_he_warhead = 1,
  },

  icbm_warhead_type = "high_explosive",

  inventory_image = "yatm_icbm_high_explosive_warhead.png",
})

-- Freezes area on detontation
minetest.register_craftitem("yatm_armoury_icbm:icbm_frost_warhead", {
  description = "ICBM FROST Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_frost_warhead = 1,
  },

  icbm_warhead_type = "frost",

  inventory_image = "yatm_icbm_frost_warhead.png",
})

-- Capsule warhead
-- Doesn't detontate, but offers inventory space
minetest.register_craftitem("yatm_armoury_icbm:icbm_capsule_warhead", {
  description = "ICBM Capsule Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_capsule_warhead = 1,
  },

  icbm_warhead_type = "capsule",

  inventory_image = "yatm_icbm_capsule_warhead.png",
})
