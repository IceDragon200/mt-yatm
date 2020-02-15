-- AMS - Azeros Munitions Standards
-- It's based on the NATO standard, so it should be easy to pick up.
-- The Azeros is a fictional organization.
yatm_armoury.ammunition_codes = {}

function yatm_armoury:register_ammunition_type(mod, params)
  local variant_code = params.code
  local variant_basename = params.basename
  local variant_name = params.name
  local variant_groups = params.groups

  self.ammunition_codes[variant_code] = {
    basename = variant_basename,
    name = variant_name,
    groups = variant_groups,
    calibres = {
      ["9x19mm"] = mod .. ":ammo_" .. variant_basename .. "_9x19mm",
      ["5.56x45mm"] = mod .. ":ammo_" .. variant_basename .. "_5p56x45mm",
      ["7.62x51mm"] = mod .. ":ammo_" .. variant_basename .. "_7p62x51mm",
      ["12.7x99mm"] = mod .. ":ammo_" .. variant_basename .. "_12p7x99mm",
      ["25x137mm"] = mod .. ":ammo_" .. variant_basename .. "_25x137mm",
      ["30x173mm"] = mod .. ":ammo_" .. variant_basename .. "_30x173mm",
      ["40x43mm-grenade"] = mod .. ":ammo_" .. variant_basename .. "_40x43mm_grenade",
      ["81mm-mortar"] = mod .. ":ammo_" .. variant_basename .. "_81mm_mortar",
    }
  }
  local ammo_def = self.ammunition_codes[variant_code]

  local groups = yatm_core.table_merge({ammunition = 1}, variant_groups)

  minetest.register_craftitem(ammo_def.calibres["9x19mm"], {
    basename = mod .. ":ammo_9x19mm",
    base_description = "AMS 9x19mm",

    description = "AMS 9x19mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_9x19mm.png",
    calibre = "9x19mm",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 256,
  })

  minetest.register_craftitem(ammo_def.calibres["5.56x45mm"], {
    basename = mod .. ":ammo_5p56x45mm",
    base_description = "AMS 5.56x45mm",

    description = "AMS 5.56x45mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_5p56x45mm.png",
    calibre = "5.56x45mm",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 192,
  })

  -- Battle Rifle Ammo
  minetest.register_craftitem(ammo_def.calibres["7.62x51mm"], {
    basename = mod .. ":ammo_7p62x51mm",
    base_description = "AMS 7.62x51mm",

    description = "AMS 7.62x51mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_7p62x51mm.png",
    calibre = "7.62x51mm",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 128,
  })

  -- Anti-Material & Machine Gun Ammo
  minetest.register_craftitem(ammo_def.calibres["12.7x99mm"], {
    basename = mod .. ":ammo_12p7x99mm",
    base_description = "AMS 12.7x99mm",

    description = "AMS 12.7x99mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_12p7x99mm.png",
    calibre = "12.7x99mm",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 96,
  })

  minetest.register_craftitem(ammo_def.calibres["25x137mm"], {
    basename = mod .. ":ammo_25x137mm",
    base_description = "AMS 25x137mm",

    description = "AMS 25x137mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_25x137mm.png",
    calibre = "25x137mm",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 64,
  })

  minetest.register_craftitem(ammo_def.calibres["30x173mm"], {
    basename = mod .. ":ammo_30x173mm",
    base_description = "AMS 30x173mm",

    description = "AMS 30x173mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_30x173mm.png",
    calibre = "30x173mm",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 32,
  })

  minetest.register_craftitem(ammo_def.calibres["40x43mm-grenade"], {
    basename = mod .. ":ammo_40x43mm_grenade",
    base_description = "AMS 40x43mm Grenade",

    description = "AMS 40x43mm Grenade " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_40x43mm_grenade.png",
    calibre = "40x43mm-grenade",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 24,
  })

  minetest.register_craftitem(ammo_def.calibres["81mm-mortar"], {
    basename = mod .. ":ammo_81mm_mortar",
    base_description = "AMS 81mm Mortar",

    description = "AMS 81mm Mortar " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_81mm_mortar.png",
    calibre = "81mm-mortar",
    ammo_code = variant_code,
    ammo_variant = variant_basename,
    stack_max = 16,
  })
end

-- Ammo Variants:
local variants = {
  -- nuclear - depleted nuclear material, causes poisoning effect, handle with care
  {"N", "nuclear", "Nuclear", {radioactive = 1}},
  -- standard - default ammunition, should have the regular effect
  {"S", "standard", "Standard", {}},
  -- he - high-explosive, should deal more damage with explosive damage
  {"X", "he", "High-Explosive", {explosive = 1}},
  -- ele - elemental round, when firing it also consumes MP from the user to deal additional damage
  {"E", "ele", "Elemental", {elemental = 1, magical = 1}},
}

if rawget(_G, "yatm_blasts_frost") then
  -- frost - FROST special issued rounds, causes a freezing effect
  table.insert(variants, {"F", "frost", "FROST", {freezing = 1}})
end

if rawget(_G, "yatm_blasts_emp") then
  -- emp - Electro Magnetic Pulse, disrupts the operation of some machines and entities
  table.insert(variants, {"M", "emp", "EMP", {emp = 1}})
end

for _index,variant_row in ipairs(variants) do
  yatm_armoury:register_ammunition_type("yatm_armoury", {
    code = variant_row[1],
    basename = variant_row[2],
    name = variant_row[3],
    groups = variant_row[4],
  })
end
