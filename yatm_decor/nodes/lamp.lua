local lamp_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.3125, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox1
    {-0.5, -0.5, -0.5, 0.5, -0.3125, 0.5}, -- NodeBox2
  }
}

minetest.register_node("yatm_decor:lamp_white_off", {
  description = "Lamp [off]",
  groups = {cracky = 1},
  tiles = {
    "yatm_lamp_top.off.png",
    "yatm_lamp_bottom.off.png",
    "yatm_lamp_side.off.png",
    "yatm_lamp_side.off.png",
    "yatm_lamp_side.off.png",
    "yatm_lamp_side.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = lamp_node_box,
})

minetest.register_node("yatm_decor:lamp_white_on", {
  description = "Lamp [on]",
  groups = {cracky = 1},
  tiles = {
    "yatm_lamp_top.on.png",
    "yatm_lamp_bottom.on.png",
    "yatm_lamp_side.on.png",
    "yatm_lamp_side.on.png",
    "yatm_lamp_side.on.png",
    "yatm_lamp_side.on.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  light_source = default.LIGHT_MAX,
  drawtype = "nodebox",
  node_box = lamp_node_box,
})
