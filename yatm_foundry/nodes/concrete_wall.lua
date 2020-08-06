local Cuboid = yatm_core.Cuboid
local ng = Cuboid.new_fast_node_box

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
    ng( 1,  0,  7, 14, 16,  2), -- top small wall
    ng( 0,  0,  6,  2, 16,  4), -- top left segment wall
    ng( 6,  0,  6,  4, 16,  4), -- top mid segment wall
    ng(14,  0,  6,  2, 16,  4), -- top right segment wall
  }
}

local concrete_wall_collision_box = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  6, 16, 16,  4),
  }
}

local concrete_wall_corner_nodebox = {
  type = "fixed",
  fixed = {
    ng( 1,  0,  7,  8, 16,  2), -- top small wall
    ng( 0,  0,  6,  2, 16,  4), -- top left segment wall
    ng( 6,  0,  6,  4, 16,  4), -- top mid segment wall

    ng( 7,  0,  1,  2, 16,  8), -- top small wall
    ng( 6,  0,  0,  4, 16,  2), -- top left segment wall
  }
}

local concrete_wall_corner_collision_box = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  6, 10, 16,  4),
    ng( 6,  0,  0,  4, 16, 10),
  }
}

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  minetest.register_node("yatm_foundry:concrete_wall_" .. color_basename, {
    basename = "yatm_foundry:concrete_wall",
    base_description = "Concrete Wall",

    description = "Concrete Wall (" .. color_name .. ")",

    codex_entry_id = "yatm_foundry:concrete_wall",

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

    collision_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 6, 16, 16, 4)
      },
    },

    selection_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 6, 16, 16, 4)
      },
    },

    is_ground_content = false,

    sounds = yatm.node_sounds:build("stone"),

    paramtype = "none",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = concrete_wall_nodebox,
    collision_box = concrete_wall_collision_box,
  })

  minetest.register_node("yatm_foundry:concrete_wall_corner_" .. color_basename, {
    basename = "yatm_foundry:concrete_wall_corner",
    base_description = "Concrete Wall Corner",

    description = "Concrete Wall Corner (" .. color_name .. ")",

    codex_entry_id = "yatm_foundry:concrete_wall_corner",

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

    sounds = yatm.node_sounds:build("stone"),

    paramtype = "none",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = concrete_wall_corner_nodebox,
    collision_box = concrete_wall_corner_collision_box,
  })
end
