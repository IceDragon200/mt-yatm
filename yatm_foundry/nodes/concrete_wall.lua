local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

local concrete_wall_nodebox = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 1,  0,  7, 14, 16,  2):fast_node_box(), -- top small wall
    yatm_core.Cuboid:new( 0,  0,  6,  2, 16,  4):fast_node_box(), -- top left segment wall
    yatm_core.Cuboid:new( 6,  0,  6,  4, 16,  4):fast_node_box(), -- top mid segment wall
    yatm_core.Cuboid:new(14,  0,  6,  2, 16,  4):fast_node_box(), -- top right segment wall
  }
}

local concrete_wall_collision_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0,  6, 16, 16,  4):fast_node_box(),
  }
}

local concrete_wall_corner_nodebox = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 1,  0,  7,  8, 16,  2):fast_node_box(), -- top small wall
    yatm_core.Cuboid:new( 0,  0,  6,  2, 16,  4):fast_node_box(), -- top left segment wall
    yatm_core.Cuboid:new( 6,  0,  6,  4, 16,  4):fast_node_box(), -- top mid segment wall

    yatm_core.Cuboid:new( 7,  0,  1,  2, 16,  8):fast_node_box(), -- top small wall
    yatm_core.Cuboid:new( 6,  0,  0,  4, 16,  2):fast_node_box(), -- top left segment wall
  }
}

local concrete_wall_corner_collision_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0,  6, 10, 16,  4):fast_node_box(),
    yatm_core.Cuboid:new( 6,  0,  0,  4, 16, 10):fast_node_box(),
  }
}

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  minetest.register_node("yatm_foundry:concrete_wall_" .. color_basename, {
    description = "Concrete Wall (" .. color_name .. ")",

    groups = {
      cracky = 1,
      concrete = 1,
      wall = 1,
    },

    tiles = {
      "yatm_concrete_wall_" .. color_basename .. "_top.png",
      "yatm_concrete_wall_" .. color_basename .. "_bottom.png",
      "yatm_concrete_wall_" .. color_basename .. "_side.png",
      "yatm_concrete_wall_" .. color_basename .. "_side.png^[transformFX",
      "yatm_concrete_wall_" .. color_basename .. "_front.png^[transformFX",
      "yatm_concrete_wall_" .. color_basename .. "_front.png",
    },

    is_ground_content = false,

    sounds = default.node_sound_stone_defaults(),

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = concrete_wall_nodebox,
    collision_box = concrete_wall_collision_box,
  })

  minetest.register_node("yatm_foundry:concrete_wall_corner_" .. color_basename, {
    description = "Concrete Wall Corner (" .. color_name .. ")",

    groups = {
      cracky = 1,
      concrete = 1,
      wall = 1,
    },

    tiles = {
      "yatm_concrete_wall_corner_" .. color_basename .. "_top.png",
      "yatm_concrete_wall_corner_" .. color_basename .. "_bottom.png",
      "yatm_concrete_wall_" .. color_basename .. "_front.png",
      "yatm_concrete_wall_" .. color_basename .. "_front.png^[transformFX",
      "yatm_concrete_wall_" .. color_basename .. "_front.png^[transformFX",
      "yatm_concrete_wall_" .. color_basename .. "_front.png",
    },

    is_ground_content = false,

    sounds = default.node_sound_stone_defaults(),

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = concrete_wall_corner_nodebox,
    collision_box = concrete_wall_corner_collision_box,
  })
end
