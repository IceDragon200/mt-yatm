yatm_foundry.autotest_suite:define_model("electric_kiln", {
  state = {
    node = { name = "yatm_foundry:electric_kiln_off" },
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
