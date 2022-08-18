yatm_refinery.autotest_suite:define_model("pump", {
  state = {
    node = { name = "yatm_refinery:pump_off" },
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
