--
--
--
local mod = assert(yatm_dscs)

minetest.register_craftitem("yatm_dscs:fluid_drive_t1", {
  basename = "yatm_dscs:fluid_drive",
  base_description = mod.S("Fluid Drive"),

  description = mod.S("Fluid Drive [32 Cells]"),

  groups = {inventory_drive = 1, fluid_drive = 1},

  inventory_image = "yatm_inventory_drives_fluid_tier1.png",

  drive_capacity = 32,
  drive_stack_size = 4000,

  stack_max = 1,
})

minetest.register_craftitem("yatm_dscs:fluid_drive_t2", {
  basename = "yatm_dscs:fluid_drive",
  base_description = mod.S("Fluid Drive"),

  description = mod.S("Fluid Drive [128 Cells]"),

  groups = {inventory_drive = 2, fluid_drive = 2},

  inventory_image = "yatm_inventory_drives_fluid_tier2.png",

  drive_capacity = 128,
  drive_stack_size = 8000,

  stack_max = 1,
})

minetest.register_craftitem("yatm_dscs:fluid_drive_t3", {
  basename = "yatm_dscs:fluid_drive",
  base_description = "Fluid Drive",

  description = mod.S("Fluid Drive [512 Cells]"),

  groups = {inventory_drive = 3, fluid_drive = 3},

  inventory_image = "yatm_inventory_drives_fluid_tier3.png",

  drive_capacity = 512,
  drive_stack_size = 16000,

  stack_max = 1,
})
