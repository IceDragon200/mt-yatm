yatm_foundry.autotest_suite:define_model("electric_furnace", {
  state = {
    node = { name = "yatm_foundry:electric_furnace_off" },
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
