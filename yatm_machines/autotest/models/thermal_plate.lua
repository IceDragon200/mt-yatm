for i,basename in ipairs({ "thermal_plate_nuclear", "thermal_plate_cooling", "thermal_plate_heating" }) do
  yatm_machines.autotest_suite:define_model(basename, {
    state = {
      node = { name = "yatm_machines:" .. basename .. "_off" },
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
end
