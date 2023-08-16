--
-- This is a test node, used for testing the security API and it's functionality
--
local mod = assert(yatm_security)

mod:register_node("secure_box", {
  description = mod.S("Secure Box"),

  codex_entry_id = mod:make_name("secure_box"),

  groups = {
    cracky = nokore.dig_class("copper"),
    secure_box = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_locksmiths_table_wood_top.png",
    "yatm_locksmiths_table_wood_bottom.png",
    "yatm_locksmiths_table_wood_side.png",
    "yatm_locksmiths_table_wood_side.png^[transformFX",
    "yatm_locksmiths_table_wood_side.png^[transformFX",
    "yatm_locksmiths_table_wood_side.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("wood"),

  security = {
    slot_ids = {
      "sec_1",
      "sec_2",
      "sec_3",
    },
  },
})
