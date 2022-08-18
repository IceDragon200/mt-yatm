yatm_machines.autotest_suite:define_model("pylon", {
  state = {
    node = { name = "yatm_machines:pylon_off" },
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
