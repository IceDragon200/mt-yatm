yatm_machines.autotest_suite:define_model("crusher", {
  state = {
    node = { name = "yatm_machines:crusher_off" },
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
