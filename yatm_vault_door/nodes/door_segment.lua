local mod = yatm_vault_door
local Directions = assert(foundation.com.Directions)
local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)

local VARIANTS = {
  {
    basename = "steel_plate",
    description = "Steel Plate",
  }
}

local node_box = {
  type = "fixed",
  fixed = {
    ng(0, 0, 7, 16, 16, 2),
  }
}

for _index, variant in pairs(VARIANTS) do
  -- Fixed door segments will not move when their frame is activated,
  -- acting as a blocking node to the segments.
  mod:register_node("vault_door_segment_fixed_" .. variant.basename, {
    description = mod.S("Vault Door Segment [Fixed] (" .. variant.description .. ")"),

    groups = {
      vault_door_segment = 1,
      vault_door_fixed = 1,
    },

    paramtype = "none",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = node_box,
    selection_box = node_box,
    collision_box = node_box,

    is_ground_content = false,
  })

  -- Movable segments as their name implies are door segments that will
  -- move when the door is activated
  mod:register_node("vault_door_segment_movable_" .. variant.basename, {
    description = mod.S("Vault Door Segment [Movable] (" .. variant.description .. ")"),

    groups = {
      vault_door_segment = 1,
    },

    paramtype = "none",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = node_box,
    selection_box = node_box,
    collision_box = node_box,

    is_ground_content = false,
  })
end
