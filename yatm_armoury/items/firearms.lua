--
-- Light Arms, named after the 72 Pillars of Solomon
-- A weapon's name comes from the cartridge size it uses.
--
-- Semi-Automatics take their name from the Cartridge Length
-- Automatics take their name from the Cartridge diameter
-- `<D>x<L>mm`
--
-- In the case of the 12.7x99mm, it instead uses the diameter only.
--
-- Names Used:
--    7 Amon
--    9 Paimon
--   12 Sitri
--   19 Sallos
--   27 Ronove [Belt fed 9x19mm]
--   45 Vine
--   51 Balam
--   56 Gremory
--   62 Valac
--
-- <Calibre>[AS]+ (e.g. 19A - meaning it uses 9x19mm and fires in Automatic-only)
--                (e.g. 45AS - meaning it uses 5.56mm and fires in either Automatic or Semi-Automatic)
--
-- `_ul` at the end of the item name, means 'unloaded'
-- `_mag` at the end of the item name, means 'loaded with magazine'
-- `_clip` at the end of the item name, means 'loaded with clip' (unused)
-- `_drum` at the end of the item name, means 'loaded with drum magazine'
-- `_belt` at the end of the item name, means 'loaded with ammunition belt'
--
-- 'smg' Sub-Machine Gun
-- 'mg' Machine Gun
-- 'hmg' Heavy Machine Gun
-- 'amr' Anti-Material Rifle
--
-- Once again AMS stands for Azeros Munitions Standard, a fictional organization.
--

-- 9x19mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_hg9mm_semi", {
  description = "AMS Sallos HG 19S",

  groups = {
    firearm = 1,
    handgun = 1,
  },

  calibre = "9x19mm",
  fire_modes = {semi = 1},
  feed_systems = {magazine = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_hg9mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_hg9mm_semi_mag.png",
  },
})

-- 9x19mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_smg9mm_auto", {
  description = "AMS Paimon SMG 19A",

  groups = {
    firearm = 1,
    sub_machine_gun = 1,
  },

  calibre = "9x19mm",
  fire_modes = {auto = 1},
  feed_systems = {magazine = 1, drum = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_smg9mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_smg9mm_auto_mag.png",
  },
  drum = {
    inventory_image = "yatm_firearms_smg9mm_auto_drum.png",
  },
})

-- 9x19mm - Automatic [Belt Feed]
yatm.register_stateful_tool("yatm_armoury:firearm_mg9mm_auto", {
  description = "AMS Ronove MG 19A",

  groups = {
    firearm = 1,
    machine_gun = 1,
  },

  calibre = "9x19mm",
  fire_modes = {auto = 1},
  feed_systems = {belt = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_mg9mm_auto_ul.png",
  },
  belt = {
    inventory_image = "yatm_firearms_mg9mm_auto_belt.png",
  },
})

-- 5.56x45mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_rfl45mm_semi", {
  description = "AMS Vine AR 45S",

  groups = {
    firearm = 1,
    sniper_rifle = 1,
  },

  calibre = "5.56x45mm",
  fire_modes = {semi = 1},
  feed_systems = {magazine = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_rfl45mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_rfl45mm_semi_mag.png",
  },
})

-- 5.56x45mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_rfl45mm_auto", {
  description = "AMS Gremory AR 45AS",

  groups = {
    firearm = 1,
    assault_rifle = 1,
  },

  calibre = "5.56x45mm",
  fire_modes = {auto = 1, semi = 1},
  feed_systems = {magazine = 1, belt = 1, drum = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_rfl45mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_rfl45mm_auto_mag.png",
  },
  belt = {
    inventory_image = "yatm_firearms_rfl45mm_auto_belt.png",
  },
  drum = {
    inventory_image = "yatm_firearms_rfl45mm_auto_drum.png",
  },
})

-- 7.62x51mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_br51mm_semi", {
  description = "AMS Balam BR 51S",

  groups = {
    firearm = 1,
    battle_rifle = 1,
    sniper_rifle = 1,
  },

  calibre = "7.62x51mm",
  fire_modes = {semi = 1},
  feed_systems = {magazine = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_br51mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_br51mm_semi_mag.png",
  },
})

-- 7.62x51mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_br51mm_auto", {
  description = "AMS Valac BR 51AS",

  groups = {
    firearm = 1,
    battle_rifle = 1,
  },

  calibre = "7.62x51mm",
  fire_modes = {auto = 1, semi = 1},
  feed_systems = {magazine = 1, belt = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_br51mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_br51mm_auto_mag.png",
  },
  belt = {
    inventory_image = "yatm_firearms_br51mm_auto_belt.png",
  },
})

-- 12.7x99mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_amr99mm_semi", {
  description = "AMS Amon AMR 99S",

  groups = {
    firearm = 1,
    anti_material_rifle = 1,
  },

  calibre = "12.7x99mm",
  fire_modes = {semi = 1},
  feed_systems = {magazine = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_amr99mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_amr99mm_semi_mag.png",
  }
})

-- 12.7x99mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_hmg99mm_auto", {
  description = "AMS Sitri HMG 99A",

  groups = {
    firearm = 1,
    machine_gun = 1,
  },

  calibre = "12.7x99mm",
  fire_modes = {auto = 1},
  feed_systems = {magazine = 1, belt = 1},

  stack_max = 1,
}, {
  ul = {
    inventory_image = "yatm_firearms_hmg99mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_hmg99mm_auto_mag.png",
  },
  belt = {
    inventory_image = "yatm_firearms_hmg99mm_auto_belt.png",
  },
})
