minetest.register_node("yatm_packs:health_pack", {
  description = "Health Pack",

  groups = {
    snappy = 2,
    choppy = 2,
    oddly_breakable_by_hand = 3,
    health_pack = 1,
  },

  tiles = {
    "yatm_health_pack_top.png",
    "yatm_health_pack_bottom.png",
    "yatm_health_pack_side.png",
    "yatm_health_pack_side.png",
    "yatm_health_pack_back.png",
    "yatm_health_pack_front.png",
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
