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

  minetest.register_craftitem("yatm_core:vacuum_tube_" .. material_basename, {
    basename = "yatm_core:vacuum_tube",
    base_description = "Vacuum Tube",

    description = material_name .. " Vacuum Tube",
    inventory_image = "yatm_materials_vacuum_tube." .. material_basename .. ".png",

    groups = {
      vacuum_tube = 1,
      ["vacuum_tube_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
