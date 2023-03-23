local mod = assert(yatm_woodcraft)

mod.autotest_suite:define_model("sawmill", {
  state = {
    node = { name = mod:make_name("sawmill") },
  },

  properties = {
    {
      property = "is_sawmill",
    },
  }
})
