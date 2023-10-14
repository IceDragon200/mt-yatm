yatm_dscs.autotest_suite:define_model("void_chest", {
  state = {
    node = { name = "yatm_dscs:void_chest_off" },
  },

  properties = {
    {
      property = "is_machine_like",
    },
    {
      property = "has_rightclick_formspec",
    },
    {
      property = "is_void_chest",
    },
  }
})
