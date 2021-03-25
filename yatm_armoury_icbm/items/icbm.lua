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
  basename = "yatm_armoury_icbm:icbm_warhead",

  base_description = "ICBM Warhead",

  description = "ICBM Nuclear Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_nuclear_warhead = 1,
  },

  icbm_warhead_type = "nuclear",

  inventory_image = "yatm_icbm_warheads_nuclear.png",
})

-- Load any fluid into the warhead, when detonated it will cause an associated effect.
--
if yatm_fluids then
  minetest.register_craftitem("yatm_armoury_icbm:icbm_chemical_warhead", {
    basename = "yatm_armoury_icbm:icbm_warhead",

    base_description = "ICBM Warhead",

    description = "ICBM Chemical Warhead",

    groups = {
      icbm_warhead = 1,
      icbm_chemical_warhead = 1,
    },

    icbm_warhead_type = "chemical",

    inventory_image = "yatm_icbm_warheads_chemical.png",
  })
end

-- Sets fire to the area when detonated
minetest.register_craftitem("yatm_armoury_icbm:icbm_incendiary_warhead", {
  basename = "yatm_armoury_icbm:icbm_warhead",

  base_description = "ICBM Warhead",

  description = "ICBM Incendiary Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_incendiary_warhead = 1,
  },

  icbm_warhead_type = "incendiary",

  inventory_image = "yatm_icbm_warheads_incendiary.png",
})

-- Explosive, deals explosive damage
minetest.register_craftitem("yatm_armoury_icbm:icbm_explosive_warhead", {
  basename = "yatm_armoury_icbm:icbm_warhead",

  base_description = "ICBM Warhead",

  description = "ICBM Explosive Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_explosive_warhead = 1,
  },

  icbm_warhead_type = "explosive",

  inventory_image = "yatm_icbm_warheads_standard.png",
})

-- High-Explosive, deals explosive damage
minetest.register_craftitem("yatm_armoury_icbm:icbm_he_warhead", {
  basename = "yatm_armoury_icbm:icbm_warhead",

  base_description = "ICBM Warhead",

  description = "ICBM HE Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_he_warhead = 1,
  },

  icbm_warhead_type = "high_explosive",

  inventory_image = "yatm_icbm_warheads_he.png",
})

-- Capsule warhead
-- Doesn't detontate, but offers inventory space
minetest.register_craftitem("yatm_armoury_icbm:icbm_capsule_warhead", {
  basename = "yatm_armoury_icbm:icbm_warhead",

  base_description = "ICBM Warhead",

  description = "ICBM Capsule Warhead",

  groups = {
    icbm_warhead = 1,
    icbm_capsule_warhead = 1,
  },

  icbm_warhead_type = "capsule",

  inventory_image = "yatm_icbm_warheads_capsule.png",
})

if yatm_blasts_frost then
  -- Freezes area on detontation
  minetest.register_craftitem("yatm_armoury_icbm:icbm_frost_warhead", {
    basename = "yatm_armoury_icbm:icbm_warhead",

    base_description = "ICBM Warhead",

    description = "ICBM FROST Warhead",

    groups = {
      icbm_warhead = 1,
      icbm_frost_warhead = 1,
    },

    icbm_warhead_type = "frost",

    inventory_image = "yatm_icbm_warheads_frost.png",
  })
end

if yatm_blasts_emp then
  -- Disrupts electrical equipment in area
  minetest.register_craftitem("yatm_armoury_icbm:icbm_emp_warhead", {
    basename = "yatm_armoury_icbm:icbm_warhead",

    base_description = "ICBM Warhead",

    description = "ICBM EMP Warhead",

    groups = {
      icbm_warhead = 1,
      icbm_emp_warhead = 1,
    },

    icbm_warhead_type = "emp",

    inventory_image = "yatm_icbm_warheads_emp.png",
  })
end
