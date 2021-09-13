--        .
--      .' '.
--    .'     '.
--  .'         '.
--  |'.       .'|
--  |  '.   .'  |
--  |    '.'    |
--  |     |     |
--  '.    |    .'
--    '.  |  .'
--      '.|.'
--        '
--
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)

-- Frames only join with other frames
local node_box = {
  type = "fixed",
  fixed = {
    ng(0, 0, 0, 16, 16, 16),
  },
}

minetest.register_node("yatm_frames:frame", {
  description = "Frame",

  codex_entry_id = "yatm_frames:frame",

  groups = {
    cracky = 1,
    node_frame = 1,
  },

  drawtype = "glasslike",
  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,
})

-- Sticky frames act like sticky pistons dragging any connected nodes with it
minetest.register_node("yatm_frames:frame_sticky_one", {
  description = "Sticky Frame (One Face)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_SOUTH},

  drawtype = "nodebox",
  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_two", {
  description = "Sticky Frame (Two Faces)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_UP, Directions.D_SOUTH},

  drawtype = "nodebox",
  node_box = node_box,

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_three", {
  description = "Sticky Frame (Three Faces)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_UP, Directions.D_EAST, Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

-- This is a different four face configuration
minetest.register_node("yatm_frames:frame_sticky_four", {
  description = "Sticky Frame (Four Faces)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_UP, Directions.D_WEST, Directions.D_EAST, Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_cross_axle", {
  description = "Sticky Frame (Cross Axle)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_WEST, Directions.D_EAST, Directions.D_NORTH, Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_five", {
  description = "Sticky Frame (Five Faces)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_UP, Directions.D_DOWN, Directions.D_WEST, Directions.D_EAST, Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky", {
  description = "Sticky Frame (All Faces)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_UP, Directions.D_DOWN, Directions.D_WEST, Directions.D_EAST, Directions.D_NORTH, Directions.D_SOUTH},

  use_texture_alpha = "blend",
  tiles = {
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,
})

minetest.register_node("yatm_frames:frame_sticky_axle", {
  description = "Sticky Frame (Axle)",

  codex_entry_id = "yatm_frames:frame_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_NORTH, Directions.D_SOUTH},

  use_texture_alpha = "blend",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

-- Wire frames, prevent other frames from connecting to it, but still affected by frame motors
minetest.register_node("yatm_frames:frame_wire_one", {
  description = "Wire Frame (One Face)",

  codex_entry_id = "yatm_frames:frame_wire",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_wire = 1,
  },

  wired_faces = {Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_wire.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_wire", {
  description = "Wire Frame (All Faces)",

  codex_entry_id = "yatm_frames:frame_wire",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_wire = 1,
  },

  wired_faces = {Directions.D_UP, Directions.D_DOWN, Directions.D_WEST, Directions.D_EAST, Directions.D_NORTH, Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side_wire.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_wire_axle", {
  description = "Wire Frame (Wire Axle)",

  codex_entry_id = "yatm_frames:frame_wire",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_wire = 1,
  },

  wired_faces = {Directions.D_NORTH, Directions.D_SOUTH},

  use_texture_alpha = "clip",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_wire.png",
    "yatm_frame_side_wire.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_wire_and_sticky_axle", {
  description = "Wire Frame (Wire & Sticky Axle)",

  codex_entry_id = "yatm_frames:frame_wire_and_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_wire = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_SOUTH},
  wired_faces = {Directions.D_NORTH},

  use_texture_alpha = "blend",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_wire.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_wire_and_sticky_cross_axle_1", {
  description = "Wire Frame (Wire & Sticky Cross Axle 1)",

  codex_entry_id = "yatm_frames:frame_wire_and_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_wire = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_NORTH, Directions.D_SOUTH},
  wired_faces = {Directions.D_WEST, Directions.D_EAST},

  use_texture_alpha = "blend",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_wire.png",
    "yatm_frame_side_wire.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_wire_and_sticky_cross_axle_2", {
  description = "Wire Frame (Wire & Sticky Cross Axle 2)",

  codex_entry_id = "yatm_frames:frame_wire_and_sticky",

  groups = {
    cracky = 1,
    node_frame = 1,
    node_frame_wire = 1,
    node_frame_sticky = 1,
  },

  sticky_faces = {Directions.D_EAST, Directions.D_SOUTH},
  wired_faces = {Directions.D_WEST, Directions.D_NORTH},

  use_texture_alpha = "blend",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_wire.png",
    "yatm_frame_side_sticky.png",
    "yatm_frame_side_wire.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})
