local mod = yatm_armoury

mod:register_tool("grenade_lemonade", {
  description = "Lemon-nade\nCaution: Handle with care",
  lore = "Not for juice.",

  groups = {
    grenade = 1,
  },

  inventory_image = "yatm_grenades_lemonade.png",
})

mod:register_tool("grenade_chemical", {
  description = "Chemical Grenade\nCaution: May or may not contain, harmful substances, up to you.",

  groups = {
    grenade = 1,
    chemical_grenade = 1,
  },

  inventory_image = "yatm_grenades_chemical_0.png",
})

mod:register_tool("grenade_incendiary", {
  description = "Incendiary Grenade\nCaution: HOT.",

  groups = {
    grenade = 1,
    incendiary_grenade = 1,
  },

  inventory_image = "yatm_grenades_fire_0.png",
})

mod:register_tool("grenade_nuclear", {
  description = "Nuclear Grenade\nCaution: Contains radioactive materials.",

  groups = {
    grenade = 1,
    nuclear_grenade = 1,
  },

  inventory_image = "yatm_grenades_nuclear_0.png",
})

if rawget(_G, "yatm_blasts_emp") then
  mod:register_tool("grenade_emp", {
    description = "EMP Grenade\nCaution: Do not throw near machines.",

    lore = "A neatly packed Grenade of electro-magnetic goodness.",

    groups = {
      grenade = 1,
      emp_grenade = 1,
    },

    inventory_image = "yatm_grenades_emp.png",
    --[[inventory_image = {
      name = "yatm_grenades_emp.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },]]
  })
end

if rawget(_G, "yatm_blasts_frost") then
  mod:register_tool("grenade_frost", {
    description = "FROST Grenade\nCold to touch.",
    lore = "An experimental grenade issued by FROST, causes freezing upon detonation.",

    groups = {
      grenade = 1,
      frost_grenade = 1,
    },

    inventory_image = "yatm_grenades_frost_0.png",
  })
end
