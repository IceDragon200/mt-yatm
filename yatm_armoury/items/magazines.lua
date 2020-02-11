--
-- Though the file says 'magazines', this also includes other feed systems.
--
-- Type
--   Magazine (_box) (considered the default capacity)
--   Clip (_clip) (unused atm)
--   Belt (_belt) (contains 2.8x a Drum)
--   Drum (_drum) (contains 5x a Magazine)
--
-- Cartridge Sizes:
--  9x19mm
--  5.56x45mm
--  7.62x51mm
--  12.7x99mm
--  25x137mm
--  30x173mm
--  40x43mm-grenade
--  81mm-mortar
--
-- The magazines only specify a capacity, the type of Cartridges is up to the user
-- For example they may load a magazine with alternating rounds
--

--
-- 9x19mm
--
minetest.register_craftitem("yatm_armoury:magazine_box_9x19mm", {
  description = "AMS Magazine 9x19mm",

  groups = {
    magazine = 1,
    box_magazine = 1,
  },

  calibre = "9x19mm",
  magazine_size = 7,

  stack_max = 1,

  inventory_image = "yatm_magazines_box_9x19mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_drum_9x19mm", {
  description = "AMS Drum Magazine 9x19mm",

  groups = {
    magazine = 1,
    drum_magazine = 1,
  },

  calibre = "9x19mm",
  magazine_size = 35,

  stack_max = 1,

  inventory_image = "yatm_magazines_drum_9x19mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_belt_9x19mm", {
  description = "AMS Cartridge Belt 9x19mm",

  groups = {
    magazine = 1,
    belt_magazine = 1,
  },

  calibre = "9x19mm",
  magazine_size = 100,

  stack_max = 1,

  inventory_image = "yatm_magazines_belt_9x19mm.png",
})

--
-- 5.56x45mm
--
minetest.register_craftitem("yatm_armoury:magazine_box_5p56x45mm", {
  description = "AMS Magazine 5.56x45mm",

  groups = {
    magazine = 1,
    box_magazine = 1,
  },

  calibre = "5.56x45mm",
  magazine_size = 30,

  stack_max = 1,

  inventory_image = "yatm_magazines_box_5p56x45mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_drum_5p56x45mm", {
  description = "AMS Drum Magazine 5.56x45mm",

  groups = {
    magazine = 1,
    drum_magazine = 1,
  },

  calibre = "5.56x45mm",
  magazine_size = 150,

  stack_max = 1,

  inventory_image = "yatm_magazines_drum_5p56x45mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_belt_5p56x45mm", {
  description = "AMS Cartridge Belt 5.56x45mm",

  groups = {
    magazine = 1,
    belt_magazine = 1,
  },

  calibre = "5.56x45mm",
  magazine_size = 420,

  stack_max = 1,

  inventory_image = "yatm_magazines_belt_5p56x45mm.png",
})

--
-- 7.62x51mm
--
minetest.register_craftitem("yatm_armoury:magazine_box_7p62x51mm", {
  description = "AMS Magazine 7.62x51mm",

  groups = {
    magazine = 1,
    box_magazine = 1,
  },

  calibre = "7.62x51mm",
  magazine_size = 10,

  stack_max = 1,

  inventory_image = "yatm_magazines_box_7p62x51mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_drum_7p62x51mm", {
  description = "AMS Drum Magazine 7.62x51mm",

  groups = {
    magazine = 1,
    drum_magazine = 1,
  },

  calibre = "7.62x51mm",
  magazine_size = 50,

  stack_max = 1,

  inventory_image = "yatm_magazines_drum_7p62x51mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_belt_7p62x51mm", {
  description = "AMS Cartridge Belt 7.62x51mm",

  groups = {
    magazine = 1,
    belt_magazine = 1,
  },

  calibre = "7.62x51mm",
  magazine_size = 140,

  stack_max = 1,

  inventory_image = "yatm_magazines_belt_7p62x51mm.png",
})

--
-- 12.7x99mm
--
minetest.register_craftitem("yatm_armoury:magazine_box_12p7x99mm", {
  description = "AMS Magazine 12.7x99mm",

  groups = {
    magazine = 1,
    box_magazine = 1,
  },

  calibre = "12.7x99mm",
  magazine_size = 5,

  stack_max = 1,

  inventory_image = "yatm_magazines_box_12p7x99mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_drum_12p7x99mm", {
  description = "AMS Drum Magazine 12.7x99mm",

  groups = {
    magazine = 1,
    drum_magazine = 1,
  },

  calibre = "12.7x99mm",
  magazine_size = 25,

  stack_max = 1,

  inventory_image = "yatm_magazines_drum_12p7x99mm.png",
})

minetest.register_craftitem("yatm_armoury:magazine_belt_12p7x99mm", {
  description = "AMS Cartridge Belt 12.7x99mm",

  groups = {
    magazine = 1,
    belt_magazine = 1,
  },

  calibre = "12.7x99mm",
  magazine_size = 70,

  stack_max = 1,

  inventory_image = "yatm_magazines_belt_12p7x99mm.png",
})


--
-- Below are Belt-only 'magazines'
-- Mostly because these are only available to turrets
--

--
-- 25x137mm
--
minetest.register_craftitem("yatm_armoury:magazine_belt_25x137mm", {
  description = "AMS Cartridge Belt 25x137mm",

  groups = {
    magazine = 1,
    belt_magazine = 1,
  },

  calibre = "25x137mm",
  magazine_size = 250,

  stack_max = 1,

  inventory_image = "yatm_magazines_belt_25x137mm.png",
})

--
-- 30x173mm
--
minetest.register_craftitem("yatm_armoury:magazine_belt_30x173mm", {
  description = "AMS Cartridge Belt 30x173mm",

  groups = {
    magazine = 1,
    belt_magazine = 1,
  },

  calibre = "30x173mm",
  magazine_size = 150,

  stack_max = 1,

  inventory_image = "yatm_magazines_belt_30x173mm.png",
})
