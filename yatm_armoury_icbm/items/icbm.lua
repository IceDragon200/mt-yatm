-- The Shell of the Missile, this is just the body of the missile
-- Individual warheads have to be attached
minetest.register_craftitem("yatm_armoury_icbm:icbm_shell", {
  description = "ICBM Shell"
})

--
-- Warheads
--

-- Nuclear Warhead, deals a lot of damage on impact, but also causes radiation damage
-- rendering the area radioactive for a period
minetest.register_craftitem("yatm_armoury_icbm:icbm_nuclear_warhead", {
  description = "ICBM Nuclear Warhead"
})

-- Load any fluid into the warhead, when detonated it will cause an associated effect.
--
minetest.register_craftitem("yatm_armoury_icbm:icbm_fluid_warhead", {
  description = "ICBM Fluid Warhead"
})


-- Sets fire to the area when detonated
minetest.register_craftitem("yatm_armoury_icbm:icbm_incendiary_warhead", {
  description = "ICBM Incendiary Warhead"
})

-- High-Explosive, deals explosive damage
minetest.register_craftitem("yatm_armoury_icbm:icbm_he_warhead", {
  description = "ICBM HE Warhead"
})

-- Freezes area on detontation
minetest.register_craftitem("yatm_armoury_icbm:icbm_frost_warhead", {
  description = "ICBM FROST Warhead"
})

-- Capsule warhead
-- Doesn't detontate, but offers inventory space
minetest.register_craftitem("yatm_armoury_icbm:icbm_capsule_warhead", {
  description = "ICBM Capsule Warhead"
})
