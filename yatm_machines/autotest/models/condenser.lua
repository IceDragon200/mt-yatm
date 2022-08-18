yatm_machines.autotest_suite:define_model("condenser", {
  state = {
    node = { name = "yatm_machines:condenser_off" },
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
