local materials

materials = {
  {"copper", "Copper"},
  {"gold", "Gold"},
  {"tin", "Tin"},
  {"carbon_steel", "Carbon Steel"},
}

minetest.register_craftitem("yatm_core:ic", {
  description = "Integrated Circuit",
  inventory_image = "yatm_materials_ic.png",

  groups = {
    ic = 1,
  },
})

minetest.register_craftitem("yatm_core:spool", {
  description = "Spool",
  inventory_image = "yatm_materials_spool.blank.png",

  groups = {
    spool_spindle = 1,
  },
})

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

materials = {
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

materials = {
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
