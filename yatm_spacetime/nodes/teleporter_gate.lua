local Cuboid = assert(foundation.com.Cuboid)
local nb = Cuboid.new_fast_node_box

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
    "yatm_teleporter_gate_side_top.base.png^[transformR90",
    "yatm_teleporter_gate_side_top.base.png",
    "yatm_teleporter_gate_top_left.base.png^[transformR270",
    "yatm_teleporter_gate_front_left.base.png^[transformFX",
    "yatm_teleporter_gate_front_left.base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      nb(0, 12, 0, 16, 4, 16), -- top
      nb(0,  0, 0,  4, 12, 16), -- left
      nb(4, 10, 3, 12, 2, 10), -- top-fins
      nb(4, 0, 3,   2, 10, 10), -- left-fins
    },
  },
})

mod:register_node("teleporter_gate_c", {
  description = "Teleporter Gate Center",

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_top_center.base.png",
    "yatm_teleporter_gate_side_middle.base.png^[transformR90",
    "yatm_teleporter_gate_side_top.base.png",
    "yatm_teleporter_gate_side_bottom.base.png",
    "yatm_teleporter_gate_front_center.base.png^[transformFX",
    "yatm_teleporter_gate_front_center.base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      nb(0, 12, 0, 16, 4, 16), -- main body
      nb(0, 10, 3, 16, 2, 10), -- fins
    },
  },
})

mod:register_node("teleporter_gate_90r", {
  description = "Teleporter Gate Right Bend",

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_top_right.base.png",
    "yatm_teleporter_gate_side_bottom.base.png^[transformR90",
    "yatm_teleporter_gate_top_right.base.png^[transformR90",
    "yatm_teleporter_gate_side_top.base.png",
    "yatm_teleporter_gate_front_right.base.png^[transformFX",
    "yatm_teleporter_gate_front_right.base.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      nb(0, 12, 0, 16, 4, 16), -- top
      nb(12, 0, 0,  4, 12, 16), -- right
      nb(0, 10, 3, 12, 2, 10), -- top-fins
      nb(10, 0, 3,  2, 10, 10), -- right-fins
    },
  },
})
