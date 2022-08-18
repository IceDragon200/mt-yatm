yatm_foundry.autotest_suite:define_model("electric_heater", {
  state = {
    node = { name = "yatm_foundry:electric_heater_off" },
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
