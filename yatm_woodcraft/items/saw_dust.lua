local mod = yatm_woodcraft

mod:register_craftitem("sawdust", {
  description = mod.S("Saw Dust"),

  groups = {
    dust = 1,
    saw_dust = 1,
  },

  inventory_image = "yatm_sawdust.png",
})
