-- Frames only join with other frames
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

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,
})

-- Sticky frames act like sticky pistons dragging any connected nodes with it
minetest.register_node("yatm_frames:frame_sticky", {
  description = "Sticky Frame (All Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky = 1,
  },

  drawtype = "glasslike",
  tiles = {
    "yatm_frame_side_sticky.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,
})

minetest.register_node("yatm_frames:frame_sticky_one", {
  description = "Sticky Frame (One Face)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky_one = 1,
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
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_two", {
  description = "Sticky Frame (Two Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky_two = 1,
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
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_three", {
  description = "Sticky Frame (Three Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky_three = 1,
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
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_four", {
  description = "Sticky Frame (Four Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky_four = 1,
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
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_five", {
  description = "Sticky Frame (Five Faces)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky_five = 1,
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
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

minetest.register_node("yatm_frames:frame_sticky_axle", {
  description = "Sticky Frame (Axle)",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_sticky_axle = 1,
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
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 16, 16):fast_node_box(),
    },
  },

  paramtype = "light",
  paramtype2 = "facedir",
})

-- Wire frames, actually I'm not sure what I'll do with them yet.
minetest.register_node("yatm_frames:frame_wire", {
  description = "Wire Frame",

  groups = {
    cracky = 1,
    motor_frame = 1,
    motor_frame_wire = 1,
  },

  drawtype = "glasslike",
  tiles = {
    "yatm_frame_side_wire.png",
  },

  paramtype = "light",
  paramtype2 = "facedir",
  place_param2 = 0,
})
