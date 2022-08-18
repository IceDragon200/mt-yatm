yatm_foundry.autotest_suite:define_model("electric_molder", {
  state = {
    node = { name = "yatm_foundry:electric_molder_off" },
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
