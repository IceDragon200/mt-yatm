yatm_machines.autotest_suite:define_model("server_controller", {
  state = {
    node = { name = "yatm_machines:server_controller_off" },
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
