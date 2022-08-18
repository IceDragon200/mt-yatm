yatm_machines.autotest_suite:define_model("network_controller", {
  state = {
    node = { name = "yatm_machines:network_controller_off" },
  },

  properties = {
    {
      property = "is_network_controller",
    },
    {
      property = "has_rightclick_formspec",
    },
  }
})
