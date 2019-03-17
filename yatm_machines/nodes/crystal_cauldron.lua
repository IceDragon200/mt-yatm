local crystal_cauldron_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1, -- the device should be updated every network step
  },
  states = {
    conflict = "yatm_machines:crystal_cauldron_error",
    error = "yatm_machines:crystal_cauldron_error",
    off = "yatm_machines:crystal_cauldron_off",
    on = "yatm_machines:crystal_cauldron_on",
  },
  passive_energy_lost = 50
}

function crystal_cauldron_yatm_network.update(pos, node)
  local nodedef = minetest.registered_nodes[node.name]
  if nodedef then
  end
end

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

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  fluid_interface_in = 1,
  fluid_interface_out = 1,
}

yatm.devices.register_network_device("yatm_machines:crystal_cauldron_off", {
  description = "Crystal Cauldron",
  groups = groups,
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

yatm.devices.register_network_device("yatm_machines:crystal_cauldron_error", {
  description = "Crystal Cauldron",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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

yatm.devices.register_network_device("yatm_machines:crystal_cauldron_on", {
  description = "Crystal Cauldron",
  groups = yatm_core.table_merge(groups, {not_in_creative_inventory = 1}),
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
