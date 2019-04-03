local assembler_yatm_network = {
  kind = "machine",
  groups = {
    item_assembler = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    has_update = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_dscs:assembler_error",
    error = "yatm_dscs:assembler_error",
    off = "yatm_dscs:assembler_off",
    on = "yatm_dscs:assembler_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0, -- assemblers won't passively start losing energy
  },
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

local groups = {
  cracky = 1,
  yatm_data_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Item Assembler",

  groups = groups,

  drop = assembler_yatm_network.states.off,

  tiles = {"yatm_assembler_side.off.png"},
  drawtype = "nodebox",
  node_box = assembler_node_box,

  selection_box = assembler_selection_box,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = assembler_yatm_network,
}, {
  on = {
    tiles = {{
      name = "yatm_assembler_side.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0
      },
    }},
  },
  error = {
    tiles = {"yatm_assembler_side.error.png"},
  }
})
