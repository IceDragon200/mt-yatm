local mod = assert(yatm_armoury_c4)

-- Tripwires emit a signal when an entity touches them
-- The tripwire must be connected to a trip_node that will receive the signal
mod:register_node("tripwire", {
  description = mod.S("Tripwire"),

  groups = {
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    tripwire = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-8/16,-8/16,-8/16,8/16,-7/16,8/16}, -- block
    }
  },
})
