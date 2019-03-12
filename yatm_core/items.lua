local materials = {
  {"copper", "Copper"},
  {"bronze", "Bronze"},
  {"gold", "Gold"},
  {"iron", "Iron"},
  {"carbon_steel", "Carbon Steel"},
}

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  minetest.register_craftitem("yatm_core:hammer_" .. material_basename, {
    description = material_name .. " Hammer",
    inventory_image = "yatm_hammer." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:battery_" .. material_basename, {
    description = material_name .. " Battery",
    inventory_image = "yatm_materials_battery." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:capacitor_" .. material_basename, {
    description = material_name .. " Capacitor",
    inventory_image = "yatm_materials_capacitor." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:gear_" .. material_basename, {
    description = material_name .. " Gear",
    inventory_image = "yatm_materials_gear." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:plate_" .. material_basename, {
    description = material_name .. " Plate",
    inventory_image = "yatm_materials_plate." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:vacuum_tube_" .. material_basename, {
    description = material_name .. " Vacuum Tube",
    inventory_image = "yatm_materials_vacuum_tube." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:dust_" .. material_basename, {
    description = material_name .. " Dust",
    inventory_image = "yatm_materials_dust." .. material_basename .. ".png",
  })

  minetest.register_craftitem("yatm_core:ingot_" .. material_basename, {
    description = material_name .. " Ingot",
    inventory_image = "yatm_materials_ingot." .. material_basename .. ".png",
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
