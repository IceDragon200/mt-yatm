-- The Shell of the Missile, this is just the body of the missile
-- Individual warheads have to be attached
minetest.register_craftitem("yatm_armoury_icbm:icbm_shell", {
  description = "ICBM Shell",

  groups = {
    icbm_shell = 1,
  },

  inventory_image = "yatm_icbm_shell.png",
})
