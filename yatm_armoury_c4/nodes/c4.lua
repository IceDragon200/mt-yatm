minetest.register_node("yatm_armoury_c4:c4_tripwired", {
  description = "C4 (Tripwire Operated)",

  groups = {
    cracky = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    --
    c4 = 1,
    explosive = 1,
    trip_node = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-8/16,-8/16,-6/16,8/16,-3/16,6/16}, -- block
    }
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_c4_plain.top.png",
    "yatm_c4_plain.bottom.png",
    "yatm_c4_plain.side.png",
    "yatm_c4_plain.side.png",
    "yatm_c4_plain.front.png",
    "yatm_c4_plain.front.png",
  },
})

minetest.register_node("yatm_armoury_c4:c4_remote", {
  description = "C4 (Remote Operated)",

  groups = {
    cracky = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    --
    c4 = 1,
    explosive = 1,
    remote_operated = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-8/16,-8/16,-6/16,8/16,-3/16,6/16}, -- block
      {-6/16,-6/16,-7/16,0/16,-1/16,7/16}, -- remote receiver
      {-7/16,-3/16, 4/16,5/16,-2/16, 5/16}, -- antena
    }
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_c4_remote.top.png",
    "yatm_c4_remote.bottom.png",
    "yatm_c4_remote.side.png",
    "yatm_c4_remote.side.png^[transformFX",
    "yatm_c4_remote.front.png^[transformFX",
    "yatm_c4_remote.front.png",
  },
})
