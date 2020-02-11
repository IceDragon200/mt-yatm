minetest.register_tool("yatm_armoury:grenade_lemonade", {
  description = "Lemon-nade\nCaution: Handle with care",
  lore = "Not for juice.",

  groups = {
    grenade = 1,
  },

  inventory_image = "yatm_grenades_lemonade.png",
})

minetest.register_tool("yatm_armoury:grenade_chemical", {
  description = "Chemical Grenade\nCaution: May or may contain, harmful substances, up to you.",

  groups = {
    grenade = 1,
    chemical_grenade = 1,
  },

  inventory_image = "yatm_grenades_chemical.png",
})

if yatm_blasts_emp then
  minetest.register_tool("yatm_armoury:grenade_emp", {
    description = "EMP Grenade\nCaution: Do not throw near machines.",
    lore = "A neatly packed Grenade of electro-magnetic goodness.",

    groups = {
      grenade = 1,
      emp_grenade = 1,
    },

    inventory_image = "yatm_grenades_emp.png",
  })
end

if yatm_blasts_frost then
  minetest.register_tool("yatm_armoury:grenade_frost", {
    description = "FROST Grenade\nCold to touch.",
    lore = "An experimental grenade issued by FROST, causes freezing upon detonation.",

    groups = {
      grenade = 1,
      frost_grenade = 1,
    },

    inventory_image = "yatm_grenades_emp.png",
  })
end
