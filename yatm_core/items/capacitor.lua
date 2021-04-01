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

  minetest.register_craftitem("yatm_core:capacitor_" .. material_basename, {
    basename = "yatm_core:capacitor",
    base_description = "Capacitor",

    description = material_name .. " Capacitor",
    inventory_image = "yatm_materials_capacitor." .. material_basename .. ".png",

    groups = {
      capacitor = 1,
      ["capacitor_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
