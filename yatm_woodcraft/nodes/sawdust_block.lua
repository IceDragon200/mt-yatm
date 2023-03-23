local mod = assert(yatm_woodcraft)

mod:register_node("sawdust_block", {
  description = mod.S("Sawdust Block"),

  drop = "yatm_woodcraft:sawdust 9",

  groups = {
    choppy = nokore.dig_class("wme"),
  },

  tiles = {
    "yatm_sawdust_base.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
  place_param2 = 0,

  sounds = nokore.node_sounds:build("wood"),
})
