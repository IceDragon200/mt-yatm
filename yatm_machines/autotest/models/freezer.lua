yatm_machines.autotest_suite:define_model("freezer", {
  state = {
    node = { name = "yatm_machines:freezer_off" },
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
