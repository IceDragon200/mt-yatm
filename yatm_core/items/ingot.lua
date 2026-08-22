local mod = assert(yatm_core)

for _,material_pair in ipairs(yatm.config.ingot_metals) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  core.register_craftitem("yatm_core:ingot_" .. material_basename, {
    basename = "yatm_core:ingot",
    base_description = mod.S("Metal Ingot"),

    description = mod.S(material_name .. " Ingot"),
    inventory_image = "yatm_materials_ingot." .. material_basename .. ".png",
    groups = {
      mat_ingot = 1,
      ["mat_ingot_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
