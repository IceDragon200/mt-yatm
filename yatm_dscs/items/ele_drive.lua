--[[
Elemental drives are used to store magical energy (Elegens, hence the 'ele')
]]
minetest.register_craftitem("yatm_dscs:ele_drive_t1", {
  description = "Elemental Drive (Tier 1)",

  groups = {inventory_drive = 1, ele_drive = 1},

  inventory_image = "yatm_inventory_drives_ele_tier1.png",
})

minetest.register_craftitem("yatm_dscs:ele_drive_t2", {
  description = "Elemental Drive (Tier 2)",

  groups = {inventory_drive = 2, ele_drive = 2},

  inventory_image = "yatm_inventory_drives_ele_tier2.png",
})

minetest.register_craftitem("yatm_dscs:ele_drive_t3", {
  description = "Elemental Drive (Tier 3)",

  groups = {inventory_drive = 3, ele_drive = 3},

  inventory_image = "yatm_inventory_drives_ele_tier3.png",
})
