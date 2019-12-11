minetest.register_craftitem("yatm_dscs:item_drive_t1", {
  description = "Item Drive [32 Cells]",

  groups = {inventory_drive = 1, item_drive = 1},

  inventory_image = "yatm_inventory_drives_item_tier1.png",

  drive_capacity = 32,
})

minetest.register_craftitem("yatm_dscs:item_drive_t2", {
  description = "Item Drive [128 Cells]",

  groups = {inventory_drive = 2, item_drive = 2},

  inventory_image = "yatm_inventory_drives_item_tier2.png",

  drive_capacity = 128,
})

minetest.register_craftitem("yatm_dscs:item_drive_t3", {
  description = "Item Drive [512 Cells]",

  groups = {inventory_drive = 3, item_drive = 3},

  inventory_image = "yatm_inventory_drives_item_tier3.png",

  drive_capacity = 512,
})
