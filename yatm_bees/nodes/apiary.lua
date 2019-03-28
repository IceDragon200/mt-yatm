local node_box = {
  type = "fixed",
  fixed = {
    {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
    {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- NodeBox2
  }
}

local groups = {
  item_interface_out = 1,
  apiary = 1,
}

minetest.register_node("yatm_bees:apiary_wood", {
  description = "Apiary (Wood)",

  groups = yatm_core.table_merge(groups, { choppy = 1 }),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_apiary_wood_top.png",
    "yatm_apiary_wood_bottom.png",
    "yatm_apiary_wood_side.png",
    "yatm_apiary_wood_side.png",
    "yatm_apiary_wood_back.png",
    "yatm_apiary_wood_front.png"
  },
  drawtype = "nodebox",
  node_box = node_box,
})

minetest.register_node("yatm_bees:apiary_metal", {
  description = "Apiary (Metal)",

  groups = yatm_core.table_merge(groups, { cracky = 1 }),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_apiary_metal_top.png",
    "yatm_apiary_metal_bottom.png",
    "yatm_apiary_metal_side.png",
    "yatm_apiary_metal_side.png",
    "yatm_apiary_metal_back.png",
    "yatm_apiary_metal_front.png"
  },
  drawtype = "nodebox",
  node_box = node_box,
})
