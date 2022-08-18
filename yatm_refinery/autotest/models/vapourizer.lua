yatm_refinery.autotest_suite:define_model("vapourizer", {
  state = {
    node = { name = "yatm_refinery:vapourizer_off" },
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
