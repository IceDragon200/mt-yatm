yatm_machines.autotest_suite:define_model("item_replicator", {
  state = {
    node = { name = "yatm_machines:item_replicator_off" },
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
