minetest.register_node("yatm_packs:mana_pack", {
  description = "Mana Pack",

  groups = {
    snappy = 2,
    choppy = 2,
    oddly_breakable_by_hand = 3,
    mana_pack = 1,
  },

  tiles = {
    "yatm_mana_pack_top.png",
    "yatm_mana_pack_bottom.png",
    "yatm_mana_pack_side.png",
    "yatm_mana_pack_side.png",
    "yatm_mana_pack_back.png",
    "yatm_mana_pack_front.png",
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
