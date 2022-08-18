yatm_machines.autotest_suite:define_model("auto_crafter", {
  state = {
    node = { name = "yatm_machines:auto_crafter_off" },
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
