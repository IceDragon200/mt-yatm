local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

local retaining_wall_nodebox = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0,  6, 16,  8,  4):fast_node_box(), -- mid wall bottom
    yatm_core.Cuboid:new( 1,  8,  7, 14,  8,  2):fast_node_box(), -- top small wall
    yatm_core.Cuboid:new( 0,  8,  6,  2,  8,  4):fast_node_box(), -- top left segment wall
    yatm_core.Cuboid:new( 6,  8,  6,  4,  8,  4):fast_node_box(), -- top mid segment wall
    yatm_core.Cuboid:new(14,  8,  6,  2,  8,  4):fast_node_box(), -- top right segment wall

    yatm_core.Cuboid:new( 1,  0,  2,  6,  2, 12):fast_node_box(), -- bottom left leg
    yatm_core.Cuboid:new( 9,  0,  2,  6,  2, 12):fast_node_box(), -- bottom right leg

    yatm_core.Cuboid:new( 2,  6,  4,  4,  2,  8):fast_node_box(), -- top left leg
    yatm_core.Cuboid:new(10,  6,  4,  4,  2,  8):fast_node_box(), -- top right leg
  }
}

local retaining_wall_collision_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0,  4, 16, 16, 12):fast_node_box(),
  }
}

local retaining_wall_corner_nodebox = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0,  6, 10,  8,  4):fast_node_box(), -- mid wall bottom - front
    yatm_core.Cuboid:new( 1,  8,  7,  8,  8,  2):fast_node_box(), -- top small wall - front
    yatm_core.Cuboid:new( 0,  8,  6,  2,  8,  4):fast_node_box(), -- top left segment wall - front
    yatm_core.Cuboid:new( 1,  0,  2,  6,  2, 12):fast_node_box(), -- bottom left leg - front
    yatm_core.Cuboid:new( 2,  6,  4,  4,  2,  8):fast_node_box(), -- top left leg - front

    yatm_core.Cuboid:new( 6,  8,  6,  4,  8,  4):fast_node_box(), -- top mid segment wall

    yatm_core.Cuboid:new( 6,  0,  0,  4,  8, 10):fast_node_box(), -- mid wall bottom - side
    yatm_core.Cuboid:new( 7,  8,  1,  2,  8,  8):fast_node_box(), -- top small wall - side
    yatm_core.Cuboid:new( 6,  8,  0,  4,  8,  2):fast_node_box(), -- top left segment wall - side
    yatm_core.Cuboid:new( 2,  0,  1, 12,  2,  6):fast_node_box(), -- bottom left leg - side
    yatm_core.Cuboid:new( 4,  6,  2,  8,  2,  4):fast_node_box(), -- top left leg - side
  }
}

local retaining_wall_corner_collision_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0,  4, 10, 16, 12):fast_node_box(),
    yatm_core.Cuboid:new( 4,  0,  0, 12, 16, 10):fast_node_box(),
  }
}

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  minetest.register_node("yatm_foundry:concrete_retaining_wall_" .. color_basename, {
    description = "Concrete Retaining Wall (" .. color_name .. ")",

    groups = {
      cracky = 1,
      concrete = 1,
      wall = 1,
    },

    tiles = {
      "yatm_retaining_wall_" .. color_basename .. "_top.png",
      "yatm_retaining_wall_" .. color_basename .. "_bottom.png",
      "yatm_retaining_wall_" .. color_basename .. "_side.png",
      "yatm_retaining_wall_" .. color_basename .. "_side.png^[transformFX",
      "yatm_retaining_wall_" .. color_basename .. "_front.png^[transformFX",
      "yatm_retaining_wall_" .. color_basename .. "_front.png",
    },

    is_ground_content = false,

    sounds = default.node_sound_stone_defaults(),

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = retaining_wall_nodebox,
    collision_box = retaining_wall_collision_box,
  })

  minetest.register_node("yatm_foundry:concrete_retaining_wall_corner_" .. color_basename, {
    description = "Concrete Retaining Wall Corner (" .. color_name .. ")",

    groups = {
      cracky = 1,
      concrete = 1,
      wall_corner = 1,
    },

    tiles = {
      "yatm_retaining_wall_corner_" .. color_basename .. "_top.png",
      "yatm_retaining_wall_corner_" .. color_basename .. "_bottom.png",
      "yatm_retaining_wall_" .. color_basename .. "_front.png",
      "yatm_retaining_wall_" .. color_basename .. "_front.png^[transformFX",
      "yatm_retaining_wall_" .. color_basename .. "_front.png^[transformFX",
      "yatm_retaining_wall_" .. color_basename .. "_front.png",
    },

    is_ground_content = false,

    sounds = default.node_sound_stone_defaults(),

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = retaining_wall_corner_nodebox,
    collision_box = retaining_wall_corner_collision_box,
  })
end
