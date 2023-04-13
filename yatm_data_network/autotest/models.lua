local mod = assert(yatm_data_network)

mod.autotest_suite:define_model("load_test", {
  state = {},

  properties = {
    {
      property = "load_test",
    },
  }
})
