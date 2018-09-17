local jukebox_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0.4375, 0.5},
    {-0.375, 0.4375, 0.0625, -0.0625, 0.5, 0.375},
    {0.0625, 0.375, 0.0625, 0.375, 0.5, 0.375},
  }
}

minetest.register_node("yatm_decor:jukebox_off", {
  description = "Jukebox [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_jukebox_top.off.png",
    "yatm_jukebox_bottom.png",
    "yatm_jukebox_east.off.png",
    "yatm_jukebox_west.off.png",
    "yatm_jukebox_back.off.png",
    "yatm_jukebox_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
  drawtype = "nodebox",
  node_box = jukebox_node_box,
})

minetest.register_node("yatm_decor:jukebox_on", {
  description = "Jukebox [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_jukebox_top.on.png",
    "yatm_jukebox_bottom.png",
    "yatm_jukebox_east.on.png",
    "yatm_jukebox_west.on.png",
    "yatm_jukebox_back.on.png",
    "yatm_jukebox_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  legacy_facedir_simple = true,
  drawtype = "nodebox",
  node_box = jukebox_node_box,
})
