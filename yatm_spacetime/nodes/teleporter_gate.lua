local mod = yatm_spacetime

local groups = {
  cracky = 1,
}

mod:register_node("teleporter_gate_90l", {
  description = "Teleporter Gate Left Bend",

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_top_left.base.png",
    "yatm_teleporter_gate_side_bottom.base.png",
    "yatm_teleporter_gate_side_top.base.png",
    "yatm_teleporter_gate_top_left.base.png",
    "yatm_teleporter_gate_front_left.base.png",
    "yatm_teleporter_gate_front_left.base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

mod:register_node("teleporter_gate_c", {
  description = "Teleporter Gate Center",

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_top_center.base.png",
    "yatm_teleporter_gate_side_middle.base.png",
    "yatm_teleporter_gate_side_top.base.png",
    "yatm_teleporter_gate_side_bottom.base.png",
    "yatm_teleporter_gate_front_center.base.png",
    "yatm_teleporter_gate_front_center.base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

mod:register_node("teleporter_gate_90r", {
  description = "Teleporter Gate Right Bend",

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_top_right.base.png",
    "yatm_teleporter_gate_side_top.base.png",
    "yatm_teleporter_gate_top_right.base.png",
    "yatm_teleporter_gate_side_bottom.base.png",
    "yatm_teleporter_gate_front_right.base.png",
    "yatm_teleporter_gate_front_right.base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
})
