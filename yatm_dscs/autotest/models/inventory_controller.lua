yatm_dscs.autotest_suite:define_model("inventory_controller", {
  state = {
    node = { name = "yatm_dscs:inventory_controller_off" },
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
