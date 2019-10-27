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
  description = "Sticky Frame",

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

  drawtype = "normal",
  tiles = {
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side.png",
    "yatm_frame_side_sticky.png",
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
