yatm_machines.autotest_suite:define_model("auto_grinder", {
  state = {
    node = { name = "yatm_machines:auto_grinder_off" },
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
