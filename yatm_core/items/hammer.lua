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
    basename = "yatm_core:hammer",
    base_description = "Hammer",

    description = material_name .. " Hammer",
    inventory_image = "yatm_hammer." .. material_basename .. ".png",

    groups = {
      hammer = 1,
      ["hammer_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
