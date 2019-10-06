-- AMS - Azeros Munitions Standards: a fictional organization, I don't feel like dipping my foot in trademark stuff.

-- Ammo Variants:
local variants = {
  -- nuclear - depleted nuclear material, causes poisoning effect, handle with care
  {"nuclear", "Nuclear", {radioactive = 1}},
  -- standard - default ammunition, should have the regular effect
  {"standard", "Standard", {}},
  -- he - high-explosive, should deal more damage with explosive damage
  {"he", "High-Explosive", {explosive = 1}},
  -- ele - elemental round, when firing it also consumes MP from the user to deal additional damage
  {"ele", "Elemental", {elemental = 1, magical = 1}},
  -- frost - FROST special issued rounds, causes a freezing effect
  {"frost", "FROST", {freezing = 1}},
}

for _index,variant_row in ipairs(variants) do
  variant_basename = variant_row[1]
  variant_name = variant_row[2]
  variant_groups = variant_row[3]

  local groups = yatm_core.table_merge({ammunition = 1}, variant_groups)

  minetest.register_craftitem("yatm_armoury:ammo_" .. variant_basename .. "_9x19mm", {
    description = "AMS 9x19mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_9x19mm.png",
    caliber = "9x19mm",
    ammo_variant = variant_basename,
    stack_max = 256,
  })

  minetest.register_craftitem("yatm_armoury:ammo_" .. variant_basename .. "_5p56x45mm", {
    description = "AMS 5.56x45mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_5p56x45mm.png",
    caliber = "5.56x45mm",
    ammo_variant = variant_basename,
    stack_max = 128,
  })

  minetest.register_craftitem("yatm_armoury:ammo_" .. variant_basename .. "_7p62x51mm", {
    description = "AMS 7.62x51mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_7p62x51mm.png",
    caliber = "7.62x51mm",
    ammo_variant = variant_basename,
    stack_max = 96,
  })

  minetest.register_craftitem("yatm_armoury:ammo_" .. variant_basename .. "_25x137mm", {
    description = "AMS 25x137mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_25x137mm.png",
    caliber = "25x137mm",
    ammo_variant = variant_basename,
    stack_max = 64,
  })

  minetest.register_craftitem("yatm_armoury:ammo_" .. variant_basename .. "_30x173mm", {
    description = "AMS 30x173mm " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_30x173mm.png",
    caliber = "30x173mm",
    ammo_variant = variant_basename,
    stack_max = 32,
  })

  minetest.register_craftitem("yatm_armoury:ammo_" .. variant_basename .. "_81mm_mortar", {
    description = "AMS 81mm Mortar " .. variant_name,
    groups = groups,
    inventory_image = "yatm_ammo_" .. variant_basename .. "_81mm_mortar.png",
    caliber = "81mm-mortar",
    ammo_variant = variant_basename,
    stack_max = 16,
  })
end
