minetest.register_node("yatm_decor:vent", {
  description = "Vent",
  groups = {
    cracky = nokore.dig_class("copper"),
  },

  tiles = {
    "yatm_vents_vent.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),
})
