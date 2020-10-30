-- Tripwires emit a signal when an entity touches them
-- The tripwire must be connected to a trip_node that will receive the signal
minetest.register_node("yatm_armoury_c4:tripwire", {
  description = "Tripwire",

  groups = {
    tripwire = 1,
  },
})
