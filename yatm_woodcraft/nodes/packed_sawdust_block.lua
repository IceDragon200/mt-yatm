minetest.register_node("yatm_woodcraft:packed_sawdust_block", {
  description = "Packed Sawdust Block",

  groups = {
    choppy = 1,
  },

  tiles = {
    "yatm_sawdust_packed.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,
})
