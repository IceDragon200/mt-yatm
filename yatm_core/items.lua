local materials = {
  "copper",
  "bronze",
  "gold",
  "iron",
  "carbon_steel",
}

for _,material in ipairs(materials) do
  minetest.register_craftitem("yatm_core:hammer_" .. material, {
    description = material .. " Hammer",
    inventory_image = "yatm_hammer." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:battery_" .. material, {
    description = material .. " Battery",
    inventory_image = "yatm_materials_battery." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:capacitor_" .. material, {
    description = material .. " Capacitor",
    inventory_image = "yatm_materials_capacitor." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:gear_" .. material, {
    description = material .. " Gear",
    inventory_image = "yatm_materials_gear." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:plate_" .. material, {
    description = material .. " Plate",
    inventory_image = "yatm_materials_plate." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:vacuum_tube_" .. material, {
    description = material .. " Vacuum Tube",
    inventory_image = "yatm_materials_vacuum_tube." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:dust_" .. material, {
    description = material .. " Dust",
    inventory_image = "yatm_materials_dust." .. material .. ".png",
  })

  minetest.register_craftitem("yatm_core:ingot_" .. material, {
    description = material .. " Ingot",
    inventory_image = "yatm_materials_ingot." .. material .. ".png",
  })
end

--[[
Elemental Crystals
]]
minetest.register_craftitem("yatm_core:crystal_carbon_steel", {
  description = "Carbon Steel Crystal",
  inventory_image = "yatm_element_crystal.carbon_steel.png",
})

minetest.register_craftitem("yatm_core:crystal_common", {
  description = "Common Crystal",
  inventory_image = "yatm_element_crystal.common.png",
})

minetest.register_craftitem("yatm_core:crystal_aqua", {
  description = "Aqua Crystal",
  inventory_image = "yatm_element_crystal.aqua.png",
})

minetest.register_craftitem("yatm_core:crystal_ignis", {
  description = "Ignis Crystal",
  inventory_image = "yatm_element_crystal.ignis.png",
})

minetest.register_craftitem("yatm_core:crystal_lux", {
  description = "Lux Crystal",
  inventory_image = "yatm_element_crystal.lux.png",
})

minetest.register_craftitem("yatm_core:crystal_terra", {
  description = "Terra Crystal",
  inventory_image = "yatm_element_crystal.terra.png",
})

minetest.register_craftitem("yatm_core:crystal_umbra", {
  description = "Umbra Crystal",
  inventory_image = "yatm_element_crystal.umbra.png",
})

minetest.register_craftitem("yatm_core:crystal_ventus", {
  description = "Ventus Crystal",
  inventory_image = "yatm_element_crystal.ventus.png",
})
