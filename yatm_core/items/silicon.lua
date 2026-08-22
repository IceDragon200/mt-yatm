local mod = assert(yatm_core)

mod:register_craftitem("silicon", {
  description = mod.S("Silicon"),

  groups = {
    mat_silicon = 1,
  },

  inventory_image = "yatm_materials.silicon.png",
})
