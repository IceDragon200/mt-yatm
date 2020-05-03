minetest.register_node("yatm_woodcraft:sawdust_block", {
  description = "Sawdust Block",

  drop = "yatm_woodcraft:sawdust 9",

  groups = {
    choppy = 2,
  },

  tiles = {
    "yatm_sawdust_base.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
  place_param2 = 0,
})
