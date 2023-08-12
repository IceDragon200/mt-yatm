local mod = assert(yatm_oku)

mod.autotest_suite:define_model("oku_micro_controller", {
  state = {
    node = { name = mod:make_name("oku_micro_controller") },
  },

  properties = {
    {
      property = "is_computer",
    },
  }
})
