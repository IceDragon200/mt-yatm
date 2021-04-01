local materials = {
  {"copper", "Copper"},
  {"gold", "Gold"},
  {"tin", "Tin"},
  {"carbon_steel", "Carbon Steel"},
}

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  minetest.register_craftitem("yatm_core:transformer_" .. material_basename, {
    basename = "yatm_core:transformer",
    base_description = "Transformer",

    description = material_name .. " Transformer",
    inventory_image = "yatm_materials_transformer." .. material_basename .. ".png",

    groups = {
      transformer = 1,
      ["transformer_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
