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

  minetest.register_craftitem("yatm_core:gear_" .. material_basename, {
    basename = "yatm_core:gear",
    base_description = "Metal Gear",

    description = material_name .. " Gear",
    inventory_image = "yatm_materials_gear." .. material_basename .. ".png",

    groups = {
      gear = 1,
      ["gear_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
