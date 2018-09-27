local crystal_cauldron_yatm_network = {
  kind = "machine",
  group = {machine = 1},
  states = {
    conflict = "yatm_machines:crystal_cauldron_error",
    error = "yatm_machines:crystal_cauldron_error",
    off = "yatm_machines:crystal_cauldron_off",
    on = "yatm_machines:crystal_cauldron_on",
  }
}

local crysytal_cauldron_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.375, -0.5, 0.5, 0.5, -0.375}, -- NodeBox1
    {-0.5, -0.375, 0.375, 0.5, 0.5, 0.5}, -- NodeBox2
    {-0.5, -0.375, -0.375, -0.375, 0.5, 0.375}, -- NodeBox3
    {0.375, -0.375, -0.375, 0.5, 0.5, 0.375}, -- NodeBox4
    {-0.5, -0.375, -0.5, 0.5, -0.1875, 0.5}, -- NodeBox5
    {-0.5, -0.5, -0.5, -0.375, -0.375, -0.375}, -- NodeBox6
    {0.375, -0.5, -0.5, 0.5, -0.375, -0.375}, -- NodeBox8
    {-0.5, -0.5, 0.375, -0.375, -0.375, 0.5}, -- NodeBox9
    {0.375, -0.5, 0.375, 0.5, -0.375, 0.5}, -- NodeBox10
  }
}

yatm_machines.register_network_device("yatm_machines:crystal_cauldron_off", {
  description = "Crystal Cauldron",
  groups = {cracky = 1},
  tiles = {
    "yatm_crystal_cauldron_top.png",
    "yatm_crystal_cauldron_bottom.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = crysytal_cauldron_node_box,
  yatm_network = crystal_cauldron_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:crystal_cauldron_error", {
  description = "Crystal Cauldron",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_crystal_cauldron_top.png",
    "yatm_crystal_cauldron_bottom.png",
    "yatm_crystal_cauldron_side.error.png",
    "yatm_crystal_cauldron_side.error.png",
    "yatm_crystal_cauldron_side.error.png",
    "yatm_crystal_cauldron_side.error.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = crysytal_cauldron_node_box,
  yatm_network = crystal_cauldron_yatm_network,
})

yatm_machines.register_network_device("yatm_machines:crystal_cauldron_on", {
  description = "Crystal Cauldron",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  tiles = {
    "yatm_crystal_cauldron_top.png",
    "yatm_crystal_cauldron_bottom.png",
    "yatm_crystal_cauldron_side.on.png",
    "yatm_crystal_cauldron_side.on.png",
    "yatm_crystal_cauldron_side.on.png",
    "yatm_crystal_cauldron_side.on.png",
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = crysytal_cauldron_node_box,
  yatm_network = crystal_cauldron_yatm_network,
})
