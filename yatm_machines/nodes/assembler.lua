local assembler_yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    has_update = 1,
  },
  states = {
    conflict = "yatm_machines:assembler_error",
    error = "yatm_machines:assembler_error",
    off = "yatm_machines:assembler_off",
    on = "yatm_machines:assembler_on",
  }
}

function assembler_yatm_network.update(pos, node, ot)
  local meta = minetest.get_meta(pos)
end

local assembler_node_box = {
  type = "fixed",
  fixed = {
    {-0.4375, -0.4375, -0.4375, 0.4375, 0.4375, 0.4375}, -- NodeBox1
    {-0.5, -0.5, -0.5, -0.375, 0.5, -0.375}, -- NodeBox2
    {0.375, -0.5, -0.5, 0.5, 0.5, -0.375}, -- NodeBox3
    {-0.5, -0.5, 0.375, -0.375, 0.5, 0.5}, -- NodeBox4
    {0.375, -0.5, 0.375, 0.5, 0.5, 0.5}, -- NodeBox5
    {-0.375, 0.375, 0.375, 0.375, 0.5, 0.5}, -- NodeBox6
    {-0.375, 0.375, -0.5, 0.375, 0.5, -0.375}, -- NodeBox7
    {-0.5, 0.375, -0.5, -0.375, 0.5, 0.5}, -- NodeBox8
    {0.375, 0.375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox9
    {-0.5, -0.5, -0.5, 0.5, -0.375, -0.375}, -- NodeBox10
    {-0.5, -0.5, 0.375, 0.5, -0.375, 0.5}, -- NodeBox11
    {-0.5, -0.5, -0.5, -0.375, -0.375, 0.5}, -- NodeBox12
    {0.375, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox13
  }
}

local assembler_selection_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
  },
}

yatm.devices.register_network_device("yatm_machines:assembler_off", {
  description = "Assembler",
  groups = {cracky = 1},
  drop = "yatm_machines:assembler_off",
  tiles = {"yatm_assembler_side.off.png"},
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = assembler_yatm_network,
  drawtype = "nodebox",
  node_box = assembler_node_box,
  selection_box = assembler_selection_box,
})

yatm.devices.register_network_device("yatm_machines:assembler_error", {
  description = "Assembler",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_machines:assembler_off",
  tiles = {"yatm_assembler_side.error.png"},
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = assembler_yatm_network,
  drawtype = "nodebox",
  node_box = assembler_node_box,
  selection_box = assembler_selection_box,
})

yatm.devices.register_network_device("yatm_machines:assembler_on", {
  description = "Assembler",
  groups = {cracky = 1, not_in_creative_inventory = 1},
  drop = "yatm_machines:assembler_off",
  tiles = {{
    name = "yatm_assembler_side.on.png",
    animation = {
      type = "vertical_frames",
      aspect_w = 16,
      aspect_h = 16,
      length = 1.0
    },
  }},
  paramtype = "light",
  paramtype2 = "facedir",
  yatm_network = assembler_yatm_network,
  drawtype = "nodebox",
  node_box = assembler_node_box,
  selection_box = assembler_selection_box,
})
