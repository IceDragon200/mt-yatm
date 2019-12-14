minetest.register_craftitem("yatm_dscs:fluid_drive_t1", {
  description = "Fluid Drive [32 Cells]",

  groups = {inventory_drive = 1, fluid_drive = 1},

  inventory_image = "yatm_inventory_drives_fluid_tier1.png",

  drive_capacity = 512,
  drive_stack_size = 4000,
})

minetest.register_craftitem("yatm_dscs:fluid_drive_t2", {
  description = "Fluid Drive [128 Cells]",

  groups = {inventory_drive = 2, fluid_drive = 2},

  inventory_image = "yatm_inventory_drives_fluid_tier2.png",

  drive_capacity = 512,
  drive_stack_size = 8000,
})

minetest.register_craftitem("yatm_dscs:fluid_drive_t3", {
  description = "Fluid Drive [512 Cells]",

  groups = {inventory_drive = 3, fluid_drive = 3},

  inventory_image = "yatm_inventory_drives_fluid_tier3.png",

  drive_capacity = 512,
  drive_stack_size = 16000,
})
