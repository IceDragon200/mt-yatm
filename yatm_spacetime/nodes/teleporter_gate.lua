local mod = assert(yatm_spacetime)

local Cuboid = assert(foundation.com.Cuboid)
local nb = Cuboid.new_fast_node_box

local groups = {
  cracky = nokore.dig_class("copper"),
}

mod:register_node("teleporter_gate_corner", {
  description = mod.S("Teleporter Gate Corner"),

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_part_corner.inner_side.png^[transformR270",
    "yatm_teleporter_gate_part_corner.outer_side.png^[transformR270",
    "yatm_teleporter_gate_part_corner.inner_side.png",
    "yatm_teleporter_gate_part_corner.outer_side.png",
    "yatm_teleporter_gate_part_corner.front.png^[transformFX",
    "yatm_teleporter_gate_part_corner.front.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      nb(0, 0, 0, 16,  4, 16), -- bottom panel
      nb(4, 4, 3, 12,  2, 10), -- bottom-fins
      nb(0, 4, 0,  4, 12, 16), -- left panel
      nb(4, 6, 3,  2, 10, 10), -- left-fins
    },
  },
})

mod:register_node("teleporter_gate_body", {
  description = mod.S("Teleporter Gate Body"),

  groups = groups,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_teleporter_gate_part_body.inner_side.png",
    "yatm_teleporter_gate_part_body.outer_side.png",
    "yatm_teleporter_gate_part_corner.inner_side.png",
    "yatm_teleporter_gate_part_corner.inner_side.png",
    "yatm_teleporter_gate_part_body.front.png",
    "yatm_teleporter_gate_part_body.front.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      nb(0, 0, 0, 16, 4, 16), -- main body
      nb(0, 4, 3, 16, 2, 10), -- fins
    },
  },
})
