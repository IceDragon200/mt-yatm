local materials = {
  {"copper", "Copper"},
  {"bronze", "Bronze"},
  {"gold", "Gold"},
  {"iron", "Iron"},
  {"tin", "Tin"},
  {"silver", "Silver"},
  {"carbon_steel", "Carbon Steel"},
}

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  minetest.register_craftitem("yatm_core:ingot_" .. material_basename, {
    basename = "yatm_core:ingot",
    base_description = "Metal Ingot",

    description = material_name .. " Ingot",
    inventory_image = "yatm_materials_ingot." .. material_basename .. ".png",
    groups = {
      ingot = 1,
      ["ingot_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
