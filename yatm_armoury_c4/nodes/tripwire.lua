local mod = assert(yatm_armoury_c4)

-- Tripwires emit a signal when an entity touches them
-- The tripwire must be connected to a trip_node that will receive the signal
mod:register_node("tripwire", {
  description = mod.S("Tripwire"),

  groups = {
    tripwire = 1,
  },
})
