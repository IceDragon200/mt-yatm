--
-- AMS stands for Azeros Munitions Standard, the Azeros is a fictional organization.
-- LLM stands for Llama Core Tek, they normally provide ammunition and grenade launchers for AMS.
--
-- Light Arms, azeros made ones are named after the 72 Pillars of Solomon
-- A weapon's name comes from the cartridge size it uses.
--
-- Semi-Automatics take their name from the Cartridge Length
-- Automatics take their name from the Cartridge diameter
-- `<D>x<L>mm`
--
-- In the case of the 12.7x99mm, it instead uses the diameter only.
--
-- Names Used (azeros):
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
-- Names Used (llama_core_tek):
--   Capybara [Grenade Launcher]
--
-- <Calibre>[AS]+ (e.g. 19A - meaning it uses 9x19mm and fires in Automatic-only)
--                (e.g. 45AS - meaning it uses 5.56x45mm and fires in either Automatic or Semi-Automatic)
--
-- `_ul` at the end of the item name, means 'unloaded'
-- `_mag` at the end of the item name, means 'loaded with magazine'
-- `_clip` at the end of the item name, means 'loaded with clip' (unused)
-- `_drum` at the end of the item name, means 'loaded with drum magazine'
-- `_belt` at the end of the item name, means 'loaded with ammunition belt'
-- `_revo` at the end of the item name, means 'loaded in revolving chamber'
--
-- 'smg' Sub-Machine Gun
-- 'mg'  Machine Gun
-- 'hmg' Heavy Machine Gun
-- 'amr' Anti-Material Rifle
-- 'gl'  Grenade Launcher
--
local sounds = assert(yatm.sounds)

sounds:register("firearm.pistol.fire", "yatm_pistol.fire", {})
sounds:register("firearm.rifle.fire", "yatm_rifle.fire", {})
sounds:register("firearm.grenade_launcher.fire", "yatm_grenade_launcher.fire", {})
sounds:register("firearm.heavy_rifle.fire", "yatm_heavy_rifle.fire", {})
sounds:register("firearm.machine_gun.reload", "yatm_machine_gun.reload", {})
sounds:register("firearm.magazine.insert", "yatm_magazine.insert", {})
sounds:register("firearm.magazine.remove", "yatm_magazine.remove", {})
sounds:register("firearm.bolt_action", "yatm_bolt_action", {})

-- firearms were designed on a 24x24 grid, the Sallos HG is the reference point
local function make_visual_scale(res)
  local a = res / 24
  return { x = a, y = a, z = 1 }
end

local function new_ballistics(params)
  local ballistics = {
    path = "linear",
    type = 'hitscan',
    sounds = params.sounds,
  }
  return ballistics
end

-- 9x19mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_hg9mm_semi", {
  description = "AMS Sallos HG 19S\nStandard issued Handgun",
  organization = "azeros",

  groups = {
    firearm = 1,
    handgun = 1,
  },

  firearm = {
    calibre = "9x19mm",
    fire_modes = {semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_hg9mm_semi_ul",
      box = "yatm_armoury:firearm_hg9mm_semi_mag",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(24),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.pistol.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_hg9mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_hg9mm_semi_mag.png",
    feed_system = "box",
  },
})

-- 9x19mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_smg9mm_auto", {
  description = "AMS Paimon SMG 19A\nVersatile SMG",
  organization = "azeros",

  groups = {
    firearm = 1,
    sub_machine_gun = 1,
  },

  firearm = {
    calibre = "9x19mm",
    fire_modes = {auto = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_smg9mm_auto_ul",
      box = "yatm_armoury:firearm_smg9mm_auto_mag",
      drum = "yatm_armoury:firearm_smg9mm_auto_drum",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(32),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.pistol.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_smg9mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_smg9mm_auto_mag.png",
    feed_system = "box",
  },
  drum = {
    inventory_image = "yatm_firearms_smg9mm_auto_drum.png",
    feed_system = "drum",
  },
})

-- 9x19mm - Automatic [Belt Feed]
yatm.register_stateful_tool("yatm_armoury:firearm_mg9mm_auto", {
  description = "AMS Ronove MG 19A\n9mm Machine Gun",
  organization = "azeros",

  groups = {
    firearm = 1,
    machine_gun = 1,
  },

  firearm = {
    calibre = "9x19mm",
    fire_modes = {auto = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_mg9mm_auto_ul",
      belt = "yatm_armoury:firearm_mg9mm_auto_belt",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(32),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.pistol.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_mg9mm_auto_ul.png",
  },
  belt = {
    inventory_image = "yatm_firearms_mg9mm_auto_belt.png",
    feed_system = "belt",
  },
})

-- 5.56x45mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_rfl45mm_semi", {
  description = "AMS Vine AR 45S",
  organization = "azeros",

  groups = {
    firearm = 1,
    sniper_rifle = 1,
  },

  firearm = {
    calibre = "5.56x45mm",
    fire_modes = {semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_rfl45mm_semi_ul",
      box = "yatm_armoury:firearm_rfl45mm_semi_mag",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(64),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.rifle.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_rfl45mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_rfl45mm_semi_mag.png",
    feed_system = "box",
  },
})

-- 5.56x45mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_rfl45mm_auto", {
  description = "AMS Gremory AR 45AS",
  organization = "azeros",

  groups = {
    firearm = 1,
    assault_rifle = 1,
  },

  firearm = {
    calibre = "5.56x45mm",
    fire_modes = {auto = 1, semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_rfl45mm_auto_ul",
      box = "yatm_armoury:firearm_rfl45mm_auto_mag",
      drum = "yatm_armoury:firearm_rfl45mm_auto_drum",
      belt = "yatm_armoury:firearm_rfl45mm_auto_belt",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(64),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.rifle.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_rfl45mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_rfl45mm_auto_mag.png",
    feed_system = "box",
  },
  belt = {
    inventory_image = "yatm_firearms_rfl45mm_auto_belt.png",
    feed_system = "belt",
  },
  drum = {
    inventory_image = "yatm_firearms_rfl45mm_auto_drum.png",
    feed_system = "drum",
  },
})

-- 7.62x51mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_br51mm_semi", {
  description = "AMS Balam BR 51S",
  organization = "azeros",

  groups = {
    firearm = 1,
    battle_rifle = 1,
    sniper_rifle = 1,
  },

  firearm = {
    calibre = "7.62x51mm",
    fire_modes = {semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_br51mm_semi_ul",
      box = "yatm_armoury:firearm_br51mm_semi_mag",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(80),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.heavy_rifle.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_br51mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_br51mm_semi_mag.png",
    feed_system = "box",
  },
})

-- 7.62x51mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_br51mm_auto", {
  description = "AMS Valac BR 51AS",
  organization = "azeros",

  groups = {
    firearm = 1,
    battle_rifle = 1,
  },

  firearm = {
    calibre = "7.62x51mm",
    fire_modes = {auto = 1, semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_br51mm_semi_ul",
      box = "yatm_armoury:firearm_br51mm_semi_mag",
      belt = "yatm_armoury:firearm_br51mm_semi_belt",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(80),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.heavy_rifle.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_br51mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_br51mm_auto_mag.png",
    feed_system = "box",
  },
  belt = {
    inventory_image = "yatm_firearms_br51mm_auto_belt.png",
    feed_system = "belt",
  },
})

-- 12.7x99mm - Semi-Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_amr99mm_semi", {
  description = "AMS Amon AMR 99S",
  organization = "azeros",

  groups = {
    firearm = 1,
    anti_material_rifle = 1,
  },

  firearm = {
    calibre = "12.7x99mm",
    fire_modes = {semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_amr99mm_semi_ul",
      box = "yatm_armoury:firearm_amr99mm_semi_mag",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(96),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.heavy_rifle.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_amr99mm_semi_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_amr99mm_semi_mag.png",
    feed_system = "box",
  }
})

-- 12.7x99mm - Automatic
yatm.register_stateful_tool("yatm_armoury:firearm_hmg99mm_auto", {
  description = "AMS Sitri HMG 99A",
  organization = "azeros",

  groups = {
    firearm = 1,
    machine_gun = 1,
  },

  firearm = {
    calibre = "12.7x99mm",
    fire_modes = {auto = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_hmg99mm_auto_ul",
      box = "yatm_armoury:firearm_hmg99mm_auto_mag",
      belt = "yatm_armoury:firearm_hmg99mm_auto_belt",
    },
  },

  stack_max = 1,

  wield_scale = make_visual_scale(96),

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.heavy_rifle.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_hmg99mm_auto_ul.png",
  },
  mag = {
    inventory_image = "yatm_firearms_hmg99mm_auto_mag.png",
    feed_system = "box",
  },
  belt = {
    inventory_image = "yatm_firearms_hmg99mm_auto_belt.png",
    feed_system = "belt",
  },
})

-- 40x43mm - Semi-Automatic Grenade Launcher
yatm.register_stateful_tool("yatm_armoury:firearm_gren43mm_semi", {
  description = "LLM Capybara GL 43S",
  organization = "llama_core_tek",

  groups = {
    firearm = 1,
    grenade_launcher = 1,
  },

  firearm = {
    calibre = "40x43mm-grenade",
    fire_modes = {semi = 1},
    allowed_feed_systems = {
      ul = "yatm_armoury:firearm_gren43mm_semi_ul",
      revolver = "yatm_armoury:firearm_gren43mm_semi_revo",
    },
  },

  stack_max = 1,

  ballistics = new_ballistics({
    sounds = {
      fire = {
        name = "firearm.grenade_launcher.fire",
        params = {},
      },
    }
  }),
  on_use = yatm_armoury.on_use_firearm,
}, {
  ul = {
    inventory_image = "yatm_firearms_gren43mm_semi_ul.png",
  },
  revo = {
    inventory_image = "yatm_firearms_gren43mm_semi_revo.png",
    feed_system = "revolver",
  },
})
