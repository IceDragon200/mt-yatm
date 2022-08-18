yatm_energy_storage_array.autotest_suite:define_model("array_energy_controller", {
  state = {
    node = { name = "yatm_energy_storage_array:array_energy_controller_off" },
  },

  properties = {
    {
      property = "is_array_energy_controller",
    },
    {
      property = "has_rightclick_formspec",
    },
  }
})
