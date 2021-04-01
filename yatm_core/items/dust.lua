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

  minetest.register_craftitem("yatm_core:dust_" .. material_basename, {
    basename = "yatm_core:dust",
    base_description = "Metal Dust",

    description = material_name .. " Dust",
    inventory_image = "yatm_materials_dust." .. material_basename .. ".png",

    groups = {
      dust = 1,
      ["dust_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
