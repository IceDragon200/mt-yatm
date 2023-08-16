local mod = assert(yatm_security)

mod.autotest_suite:define_model("secure_box", {
  state = {
    node = { name = mod:make_name("secure_box") },
  },

  properties = {
    {
      property = "is_secure_box",
    },
  }
})
