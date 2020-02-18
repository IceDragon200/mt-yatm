-- AMS - Azeros Munitions Standards
-- It's based on the NATO standard, so it should be easy to pick up.
-- The Azeros is a fictional organization.
yatm_armoury.ammunition_classes = {}
yatm_armoury.calibre_classes = {}

function yatm_armoury:register_calibre_class(name, definition)
  self.calibre_classes[name] = definition
end

function yatm_armoury:get_calibre_class(name)
  return self.calibre_classes[name]
end

function yatm_armoury:get_ammunition_class_by_code(code)
  return yatm_armoury.ammunition_classes[code]
end

function yatm_armoury:update_ammunition_class(code, params)
  yatm_armoury.ammunition_classes[code] = yatm_core.table_merge(yatm_armoury.ammunition_classes[code], params)
  return yatm_armoury.ammunition_classes[code]
end

function yatm_armoury:register_ammunition_class(mod_name, params)
  local variant_code = params.code
  local variant_basename = params.basename
  local variant_name = params.name
  local variant_groups = params.groups

  self.ammunition_classes[variant_code] = yatm_core.table_merge(params, {
    code = variant_code,
    basename = variant_basename,
    name = variant_name,
    groups = variant_groups,
    calibres = {
      ["9x19mm"] = mod_name .. ":ammo_" .. variant_basename .. "_9x19mm",
      ["5.56x45mm"] = mod_name .. ":ammo_" .. variant_basename .. "_5p56x45mm",
      ["7.62x51mm"] = mod_name .. ":ammo_" .. variant_basename .. "_7p62x51mm",
      ["12.7x99mm"] = mod_name .. ":ammo_" .. variant_basename .. "_12p7x99mm",
      ["25x137mm"] = mod_name .. ":ammo_" .. variant_basename .. "_25x137mm",
      ["30x173mm"] = mod_name .. ":ammo_" .. variant_basename .. "_30x173mm",
      ["40x43mm-grenade"] = mod_name .. ":ammo_" .. variant_basename .. "_40x43mm_grenade",
      ["81mm-mortar"] = mod_name .. ":ammo_" .. variant_basename .. "_81mm_mortar",
    }
  })
  local ammo_def = self.ammunition_classes[variant_code]

  local groups = yatm_core.table_merge({cartridge = 1}, variant_groups)

  minetest.register_craftitem(ammo_def.calibres["9x19mm"], {
    basename = mod_name .. ":ammo_9x19mm",
    base_description = "AMS 9x19mm",

    description = "AMS 9x19mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_9x19mm.png",

    cartridge = {
      calibre = "9x19mm",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },

    stack_max = 256,
  })

  minetest.register_craftitem(ammo_def.calibres["5.56x45mm"], {
    basename = mod_name .. ":ammo_5p56x45mm",
    base_description = "AMS 5.56x45mm",

    description = "AMS 5.56x45mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_5p56x45mm.png",
    cartridge = {
      calibre = "5.56x45mm",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 192,
  })

  -- Battle Rifle Ammo
  minetest.register_craftitem(ammo_def.calibres["7.62x51mm"], {
    basename = mod_name .. ":ammo_7p62x51mm",
    base_description = "AMS 7.62x51mm",

    description = "AMS 7.62x51mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_7p62x51mm.png",
    cartridge = {
      calibre = "7.62x51mm",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 128,
  })

  -- Anti-Material & Machine Gun Ammo
  minetest.register_craftitem(ammo_def.calibres["12.7x99mm"], {
    basename = mod_name .. ":ammo_12p7x99mm",
    base_description = "AMS 12.7x99mm",

    description = "AMS 12.7x99mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_12p7x99mm.png",
    cartridge = {
      calibre = "12.7x99mm",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 96,
  })

  minetest.register_craftitem(ammo_def.calibres["25x137mm"], {
    basename = mod_name .. ":ammo_25x137mm",
    base_description = "AMS 25x137mm",

    description = "AMS 25x137mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_25x137mm.png",
    cartridge = {
      calibre = "25x137mm",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 64,
  })

  minetest.register_craftitem(ammo_def.calibres["30x173mm"], {
    basename = mod_name .. ":ammo_30x173mm",
    base_description = "AMS 30x173mm",

    description = "AMS 30x173mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_30x173mm.png",
    cartridge = {
      calibre = "30x173mm",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 32,
  })

  minetest.register_craftitem(ammo_def.calibres["40x43mm-grenade"], {
    basename = mod_name .. ":ammo_40x43mm_grenade",
    base_description = "AMS 40x43mm Grenade",

    description = "AMS 40x43mm Grenade " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_40x43mm_grenade.png",
    cartridge = {
      calibre = "40x43mm-grenade",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 24,
  })

  minetest.register_craftitem(ammo_def.calibres["81mm-mortar"], {
    basename = mod_name .. ":ammo_81mm_mortar",
    base_description = "AMS 81mm Mortar",

    description = "AMS 81mm Mortar " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_81mm_mortar.png",
    cartridge = {
      calibre = "81mm-mortar",
      ammo_code = variant_code,
      ammo_variant = variant_basename,
    },
    stack_max = 16,
  })

  return self.ammunition_classes[variant_code]
end

-- NOTE: ballistics... is kinda hard, now that I look at it
--       one day I'll revise the system, but for now, I'll just throw some numbers in their
--       for testing.

yatm_armoury:register_calibre_class("9x19mm", {
  range = 16 * 3, -- nodes
})

yatm_armoury:register_calibre_class("5.56x45mm", {
  range = 16 * 4, -- nodes
})

yatm_armoury:register_calibre_class("7.62x51mm", {
  range = 16 * 5, -- nodes
})

yatm_armoury:register_calibre_class("12.7x99mm", {
  range = 16 * 6, -- nodes
})

yatm_armoury:register_calibre_class("25x137mm", {
  range = 16 * 7, -- nodes
})

yatm_armoury:register_calibre_class("30x173mm", {
  range = 16 * 7, -- nodes
})

yatm_armoury:register_calibre_class("40x43mm-grenade", {
  range = 16 * 2, -- nodes
})

yatm_armoury:register_calibre_class("81mm-mortar", {
  range = 16 * 5, -- nodes
})

-- Ammo Variants:
-- nuclear - depleted nuclear material, causes poisoning effect, handle with care
yatm_armoury:register_ammunition_class("yatm_armoury", {
  code = "N",
  basename = "nuclear",
  name = "Nuclear",
  groups = {nuclear = 1, radioactive = 1},
})

-- standard - default ammunition, should have the regular effect
yatm_armoury:register_ammunition_class("yatm_armoury", {
  code = "S",
  basename = "standard",
  name = "Standard",
  groups = {},
})

-- he - high-explosive, should deal more damage with explosive damage
yatm_armoury:register_ammunition_class("yatm_armoury", {
  code = "X",
  basename = "he",
  name = "High-Explosive",
  groups = {explosive = 1},
})

-- ele - elemental round, when firing it also consumes MP from the user to deal additional damage
yatm_armoury:register_ammunition_class("yatm_armoury", {
  code = "E",
  basename = "ele",
  name = "Elemental",
  groups = {elemental = 1, magical = 1},
})


if rawget(_G, "yatm_blasts_frost") then
  -- frost - FROST special issued rounds, causes a freezing effect
  yatm_armoury:register_ammunition_class("yatm_armoury", {
    code = "F",
    basename = "frost",
    name = "Frost",
    groups = {freezing = 1},
  })
end

if rawget(_G, "yatm_blasts_emp") then
  -- emp - Electro Magnetic Pulse, disrupts the operation of some machines and entities
  yatm_armoury:register_ammunition_class("yatm_armoury", {
    code = "M",
    basename = "emp",
    name = "EMP",
    groups = {emp = 1},
  })
end
