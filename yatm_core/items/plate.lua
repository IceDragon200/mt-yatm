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

  minetest.register_craftitem("yatm_core:plate_" .. material_basename, {
    basename = "yatm_core:plate",
    base_description = "Metal Plate",

    description = material_name .. " Plate",
    inventory_image = "yatm_materials_plate." .. material_basename .. ".png",

    groups = {
      plate = 1,
      ["plate_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
