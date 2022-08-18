yatm_foundry.autotest_suite:define_model("electric_smelter", {
  state = {
    node = { name = "yatm_foundry:electric_smelter_off" },
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
