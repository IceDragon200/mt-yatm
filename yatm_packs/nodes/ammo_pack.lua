minetest.register_node("yatm_packs:ammo_pack", {
  description = "Ammo Pack",

  groups = {
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    --
    ammo_pack = 1,
  },

  tiles = {
    "yatm_ammo_pack_top.png",
    "yatm_ammo_pack_bottom.png",
    "yatm_ammo_pack_side.png",
    "yatm_ammo_pack_side.png",
    "yatm_ammo_pack_back.png",
    "yatm_ammo_pack_front.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-8/16,-8/16,-6/16,8/16,8/16,6/16}
    }
  },

  paramtype = "light",
  paramtype2 = "facedir",
})
