yatm_machines.autotest_suite:define_model("electrolyser", {
  state = {
    node = { name = "yatm_machines:electrolyser_off" },
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
