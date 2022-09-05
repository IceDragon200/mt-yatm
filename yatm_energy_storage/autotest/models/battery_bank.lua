yatm_energy_storage.autotest_suite:define_model("battery_bank", {
  state = {
    node = { name = "yatm_energy_storage:battery_bank_off" },
  },

  properties = {
    {
      property = "is_network_controller_like",
    },
    {
      property = "has_rightclick_formspec",
    },
  }
})
