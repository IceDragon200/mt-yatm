yatm_machines.autotest_suite:define_model("combustion_engine", {
  state = {
    node = { name = "yatm_machines:combustion_engine_off" },
  },

  properties = {
    {
      property = "is_network_controller_like",
    },
    {
      property = "has_rightclick_formspec",
    },
  }
})
