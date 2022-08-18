yatm_refinery.autotest_suite:define_model("boiler", {
  state = {
    node = { name = "yatm_refinery:boiler_off" },
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
