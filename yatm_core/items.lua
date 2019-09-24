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
  inventory_image = "yatm_materials_spool.png",

  groups = {
    spool_spindle = 1,
  },
})

for _,material_pair in ipairs(materials) do
  local material_basename = material_pair[1]
  local material_name = material_pair[2]

  minetest.register_craftitem("yatm_core:spool_" .. material_basename, {
    description = material_name .. " Spool",
    inventory_image = "yatm_materials_spool." .. material_basename .. ".png",

    groups = {
      spool = 1,
      ["spool_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:transformer_" .. material_basename, {
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
    description = material_name .. " Hammer",
    inventory_image = "yatm_hammer." .. material_basename .. ".png",

    groups = {
      hammer = 1,
      ["hammer_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:battery_" .. material_basename, {
    description = material_name .. " Battery",
    inventory_image = "yatm_materials_battery." .. material_basename .. ".png",

    groups = {
      battery = 1,
      ["battery_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:capacitor_" .. material_basename, {
    description = material_name .. " Capacitor",
    inventory_image = "yatm_materials_capacitor." .. material_basename .. ".png",

    groups = {
      capacitor = 1,
      ["capacitor_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:gear_" .. material_basename, {
    description = material_name .. " Gear",
    inventory_image = "yatm_materials_gear." .. material_basename .. ".png",

    groups = {
      gear = 1,
      ["gear_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:plate_" .. material_basename, {
    description = material_name .. " Plate",
    inventory_image = "yatm_materials_plate." .. material_basename .. ".png",

    groups = {
      plate = 1,
      ["plate_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:vacuum_tube_" .. material_basename, {
    description = material_name .. " Vacuum Tube",
    inventory_image = "yatm_materials_vacuum_tube." .. material_basename .. ".png",

    groups = {
      vacuum_tube = 1,
      ["vacuum_tube_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:dust_" .. material_basename, {
    description = material_name .. " Dust",
    inventory_image = "yatm_materials_dust." .. material_basename .. ".png",

    groups = {
      dust = 1,
      ["dust_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })

  minetest.register_craftitem("yatm_core:ingot_" .. material_basename, {
    description = material_name .. " Ingot",
    inventory_image = "yatm_materials_ingot." .. material_basename .. ".png",
    groups = {
      ingot = 1,
      ["ingot_" .. material_basename] = 1,
    },

    material_name = material_basename,
  })
end

--[[
Elemental Crystals
]]
minetest.register_craftitem("yatm_core:crystal_carbon_steel", {
  description = "Carbon Steel Crystal",
  inventory_image = "yatm_element_crystal.carbon_steel.png",

  groups = {
    crystal = 1,
    crystal_carbon_steel = 1
  },

  material_name = "crystal_carbon_steel",
})

minetest.register_craftitem("yatm_core:crystal_common", {
  description = "Common Crystal",
  inventory_image = "yatm_element_crystal.common.png",

  groups = {
    crystal = 1,
    crystal_common = 1
  },
})

minetest.register_craftitem("yatm_core:crystal_aqua", {
  description = "Aqua Crystal",
  inventory_image = "yatm_element_crystal.aqua.png",

  groups = {
    crystal = 1,
    crystal_aqua = 1
  },
})

minetest.register_craftitem("yatm_core:crystal_ignis", {
  description = "Ignis Crystal",
  inventory_image = "yatm_element_crystal.ignis.png",

  groups = {
    crystal = 1,
    crystal_ignis = 1
  },
})

minetest.register_craftitem("yatm_core:crystal_lux", {
  description = "Lux Crystal",
  inventory_image = "yatm_element_crystal.lux.png",

  groups = {
    crystal = 1,
    crystal_lux = 1
  },
})

minetest.register_craftitem("yatm_core:crystal_terra", {
  description = "Terra Crystal",
  inventory_image = "yatm_element_crystal.terra.png",

  groups = {
    crystal = 1,
    crystal_terra = 1
  },
})

minetest.register_craftitem("yatm_core:crystal_umbra", {
  description = "Umbra Crystal",
  inventory_image = "yatm_element_crystal.umbra.png",

  groups = {
    crystal = 1,
    crystal_umbra = 1
  },
})

minetest.register_craftitem("yatm_core:crystal_ventus", {
  description = "Ventus Crystal",
  inventory_image = "yatm_element_crystal.ventus.png",

  groups = {
    crystal = 1,
    crystal_ventus = 1
  },
})
