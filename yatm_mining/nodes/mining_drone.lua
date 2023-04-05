local mod = assert(yatm_mining)

local Cuboid = assert(foundation.com.Cuboid)
local ng = assert(Cuboid.new_fast_node_box)

mod:register_node("mining_drone_on", {
  description = mod.S("Mining Drone"),

  groups = {
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    mining_drone = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 11, 16),
      ng(3, 11, 3, 10, 2, 10),
    },
  },
  use_texture_alpha = "clip",
  tiles = {
    "yatm_mining_drone_top.on.png",
    {
      name = "yatm_mining_drone_bottom.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
    {
      name = "yatm_mining_drone_side.left.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
    {
      name = "yatm_mining_drone_side.right.on.png^[transformFX",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
    {
      name = "yatm_mining_drone_back.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
    {
      name = "yatm_mining_drone_front.on.png",
      animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25
      },
    },
  }
})
