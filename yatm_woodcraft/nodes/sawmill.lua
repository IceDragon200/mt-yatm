local function sawmill_on_construct ()
end

minetest.register_node("yatm_woodcraft:sawmill", {
  basename = "yatm_woodcraft:sawmill",

  description = "Sawmill",

  groups = {
    cracky = 1,
    sawmill = 1,
  },

  tiles = {
    "yatm_sawmill_top.png",
    "yatm_sawmill_bottom.png",
    "yatm_sawmill_side.png",
    "yatm_sawmill_side.png",
    "yatm_sawmill_front.png",
    "yatm_sawmill_back.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = sawmill_on_construct,
})
