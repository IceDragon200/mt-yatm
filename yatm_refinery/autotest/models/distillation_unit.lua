yatm_refinery.autotest_suite:define_model("distillation_unit", {
  state = {
    node = { name = "yatm_refinery:distillation_unit_off" },
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
