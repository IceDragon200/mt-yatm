yatm_machines.autotest_suite:define_model("steam_turbine", {
  state = {
    node = { name = "yatm_machines:steam_turbine_off" },
  },

  properties = {
    {
      property = "is_machine_like",
    },
    {
      property = "has_rightclick_formspec",
    },
    {
      property = "is_steam_turbine",
    },
  }
})
