yatm_dscs.autotest_suite:define_model("drive_case", {
  state = {
    node = { name = "yatm_dscs:drive_case_off" },
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
