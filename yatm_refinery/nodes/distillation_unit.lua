yatm.devices.register_stateful_network_device({
  description = "Distillation Unit",

  groups = {cracky = 1, fluid_interface_in = 1, fluid_interface_out = 1},

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_distillation_unit_top.off.png",
    "yatm_distillation_unit_bottom.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
    "yatm_distillation_unit_side.off.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
      {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- NodeBox2
      {-0.4375, -0.25, -0.4375, 0.4375, 0.3125, 0.4375}, -- NodeBox3
      {-0.5, -0.25, -0.25, 0.5, 0.25, 0.25}, -- NodeBox4
      {-0.25, -0.25, -0.5, 0.25, 0.25, 0.5}, -- NodeBox5
    }
  },

  yatm_network = {
    kind = "machine",
    groups = {
      machine_worker = 1,
      energy_consumer = 1,
      fluid_consumer = 1,
      fluid_producer = 1,
      distillation_unit = 1,
    },
    default_state = "off",
    states = {
      on = "yatm_refinery:distillation_unit_on",
      off = "yatm_refinery:distillation_unit_off",
      error = "yatm_refinery:distillation_unit_error",
      conflict = "yatm_refinery:distillation_unit_conflict",
    },

    energy = {
      capacity = 4000,
      passive_energy_lost = 0,
    },
  },
}, {
  on = {
    tiles = {
      "yatm_distillation_unit_top.on.png",
      "yatm_distillation_unit_bottom.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
      "yatm_distillation_unit_side.on.png",
    },
  }
})
