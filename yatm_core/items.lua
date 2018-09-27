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
end
