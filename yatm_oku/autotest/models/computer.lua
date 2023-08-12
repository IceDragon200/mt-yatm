local mod = assert(yatm_oku)

mod.autotest_suite:define_model("computer", {
  state = {
    node = { name = mod:make_name("computer_off") },
  },

  properties = {
    {
      property = "is_computer",
    },
    {
      property = "is_machine_like",
    },
  }
})
