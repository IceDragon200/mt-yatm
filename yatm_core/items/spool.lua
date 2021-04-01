minetest.register_craftitem("yatm_core:spool", {
  description = "Spool",
  inventory_image = "yatm_materials_spool.blank.png",

  groups = {
    spool_spindle = 1,
  },
})

local materials = {
  {"copper", "Copper"},
  {"gold", "Gold"},
  {"tin", "Tin"},
  {"carbon_steel", "Carbon Steel"},
}

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  minetest.register_craftitem("yatm_core:spool_" .. material_basename, {
    basename = "yatm_core:spool_wire",
    base_description = "Wire Spool",

    description = material_name .. " Spool",
    inventory_image = "yatm_materials_spool." .. material_basename .. ".png",

    groups = {
      spool = 1,
      ["spool_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end
