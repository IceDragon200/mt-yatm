minetest.register_node("yatm_machines:coal_generator_off", {
  description = "Coal Generator [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_coal_generator_top.off.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.png",
    "yatm_coal_generator_side.png",
    "yatm_coal_generator_side.png",
    "yatm_coal_generator_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_machines:coal_generator_on", {
  description = "Coal Generator [on]",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_coal_generator_top.on.png",
    "yatm_coal_generator_bottom.png",
    "yatm_coal_generator_side.png",
    "yatm_coal_generator_side.png",
    "yatm_coal_generator_side.png",
    "yatm_coal_generator_front.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
})
