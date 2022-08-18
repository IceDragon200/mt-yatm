yatm_machines.autotest_suite:define_model("compactor", {
  state = {
    node = { name = "yatm_machines:compactor_off" },
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
