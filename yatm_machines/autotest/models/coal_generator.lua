yatm_machines.autotest_suite:define_model("coal_generator", {
  state = {
    node = { name = "yatm_machines:coal_generator_off" },
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
