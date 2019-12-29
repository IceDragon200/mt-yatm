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

-- Frames only join with other frames
local node_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
  },
}

minetest.register_node("yatm_frames:frame", {
  description = "Frame",

  groups = {
    cracky = 1,
    motor_frame = 1,
  },

  drawtype = "glasslike",
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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_SOUTH},

  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_two", {
  description = "Sticky Frame (Two Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_UP, yatm_core.D_SOUTH},

  tiles = {
    "yatm_frame_side_sticky.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
  },

  drawtype = "nodebox",
  node_box = node_box,

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_three", {
  description = "Sticky Frame (Three Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_UP, yatm_core.D_EAST, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_UP, yatm_core.D_WEST, yatm_core.D_EAST, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_WEST, yatm_core.D_EAST, yatm_core.D_NORTH, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_UP, yatm_core.D_DOWN, yatm_core.D_WEST, yatm_core.D_EAST, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_UP, yatm_core.D_DOWN, yatm_core.D_WEST, yatm_core.D_EAST, yatm_core.D_NORTH, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_NORTH, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
  },

  wired_faces = {yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
  },

  wired_faces = {yatm_core.D_UP, yatm_core.D_DOWN, yatm_core.D_WEST, yatm_core.D_EAST, yatm_core.D_NORTH, yatm_core.D_SOUTH},

  drawtype = "glasslike",
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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
  },

  wired_faces = {yatm_core.D_NORTH, yatm_core.D_SOUTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_SOUTH},
  wired_faces = {yatm_core.D_NORTH},

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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_NORTH, yatm_core.D_SOUTH},
  wired_faces = {yatm_core.D_WEST, yatm_core.D_EAST},

  drawtype = "glasslike",
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

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
    motor_frame_sticky = 1,
  },

  sticky_faces = {yatm_core.D_EAST, yatm_core.D_SOUTH},
  wired_faces = {yatm_core.D_WEST, yatm_core.D_NORTH},

  drawtype = "glasslike",
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
