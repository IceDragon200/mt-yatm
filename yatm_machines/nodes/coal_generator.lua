local server_yatm_network = {
  kind = "power_generator",
  group = {power_generator = 1}
}

minetest.register_node("yatm_machines:coal_generator_off", {
  description = "Coal Generator",
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
  yatm_network = server_yatm_network,
})

minetest.register_node("yatm_machines:coal_generator_on", {
  description = "Coal Generator",
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
  yatm_network = server_yatm_network,
})
