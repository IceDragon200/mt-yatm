--
-- Elemental drives are used to store magical energy (Elegens, hence the 'ele')
--
minetest.register_craftitem("yatm_dscs:ele_drive_t1", {
  basename = "yatm_dscs:ele_drive",
  base_description = "Elemental Drive",

  description = "Elemental Drive (Tier 1)",

  groups = {inventory_drive = 1, ele_drive = 1},

  inventory_image = "yatm_inventory_drives_ele_tier1.png",

  drive_capacity = 32,

  stack_max = 1,
})

minetest.register_craftitem("yatm_dscs:ele_drive_t2", {
  basename = "yatm_dscs:ele_drive",
  base_description = "Elemental Drive",

  description = "Elemental Drive (Tier 2)",

  groups = {inventory_drive = 2, ele_drive = 2},

  inventory_image = "yatm_inventory_drives_ele_tier2.png",

  drive_capacity = 128,

  stack_max = 1,
})

minetest.register_craftitem("yatm_dscs:ele_drive_t3", {
  basename = "yatm_dscs:ele_drive",
  base_description = "Elemental Drive",

  description = "Elemental Drive (Tier 3)",

  groups = {inventory_drive = 3, ele_drive = 3},

  inventory_image = "yatm_inventory_drives_ele_tier3.png",

  drive_capacity = 512,

  stack_max = 1,
})
