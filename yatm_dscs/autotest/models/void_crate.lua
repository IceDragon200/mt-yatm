yatm_dscs.autotest_suite:define_model("void_crate", {
  state = {
    node = { name = "yatm_dscs:void_crate_off" },
  },

  properties = {
    {
      property = "is_machine_like",
    },
    {
      property = "has_rightclick_formspec",
    },
    {
      property = "is_void_crate",
    },
  }
})
