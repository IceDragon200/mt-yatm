local crystal_cauldron_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    fluid_consumer = 1,
    fluid_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:crystal_cauldron_error",
    error = "yatm_machines:crystal_cauldron_error",
    off = "yatm_machines:crystal_cauldron_off",
    on = "yatm_machines:crystal_cauldron_on",
  },
  energy = {
    passive_lost = 50,
    capacity = 12000,
    startup_threshold = 1000,
    network_charge_bandwidth = 2000,
  },
}

function crystal_cauldron_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  return 0
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

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:crystal_cauldron",

  description = "Crystal Cauldron",

  groups =  {
    cracky = 1,
    item_interface_in = 1,
    item_interface_out = 1,
    fluid_interface_in = 1,
    fluid_interface_out = 1,
  },

  drop = crystal_cauldron_yatm_network.states.off,

  tiles = {
    "yatm_crystal_cauldron_top.png",
    "yatm_crystal_cauldron_bottom.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
    "yatm_crystal_cauldron_side.off.png",
  },
  drawtype = "nodebox",
  node_box = crysytal_cauldron_node_box,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = crystal_cauldron_yatm_network,
}, {
  on = {
    tiles = {
      "yatm_crystal_cauldron_top.png",
      "yatm_crystal_cauldron_bottom.png",
      "yatm_crystal_cauldron_side.on.png",
      "yatm_crystal_cauldron_side.on.png",
      "yatm_crystal_cauldron_side.on.png",
      "yatm_crystal_cauldron_side.on.png",
    },
  },
  error = {
    tiles = {
      "yatm_crystal_cauldron_top.png",
      "yatm_crystal_cauldron_bottom.png",
      "yatm_crystal_cauldron_side.error.png",
      "yatm_crystal_cauldron_side.error.png",
      "yatm_crystal_cauldron_side.error.png",
      "yatm_crystal_cauldron_side.error.png",
    },
  }
})
