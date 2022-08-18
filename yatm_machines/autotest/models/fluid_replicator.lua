yatm_machines.autotest_suite:define_model("fluid_replicator", {
  state = {
    node = { name = "yatm_machines:fluid_replicator_off" },
  },

  properties = {
    {
      property = "is_machine_like",
    },
    {
      property = "has_rightclick_formspec",
    },
  }
})
