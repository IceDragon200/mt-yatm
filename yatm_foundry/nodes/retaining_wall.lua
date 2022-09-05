local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local retaining_wall_nodebox = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  6, 16,  8,  4), -- mid wall bottom
    ng( 1,  8,  7, 14,  8,  2), -- top small wall
    ng( 0,  8,  6,  2,  8,  4), -- top left segment wall
    ng( 6,  8,  6,  4,  8,  4), -- top mid segment wall
    ng(14,  8,  6,  2,  8,  4), -- top right segment wall

    ng( 1,  0,  2,  6,  2, 12), -- bottom left leg
    ng( 9,  0,  2,  6,  2, 12), -- bottom right leg

    ng( 2,  6,  4,  4,  2,  8), -- top left leg
    ng(10,  6,  4,  4,  2,  8), -- top right leg
  }
}

local retaining_wall_collision_box = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  4, 16, 16, 12),
  }
}

local retaining_wall_corner_nodebox = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  6, 10,  8,  4), -- mid wall bottom - front
    ng( 1,  8,  7,  8,  8,  2), -- top small wall - front
    ng( 0,  8,  6,  2,  8,  4), -- top left segment wall - front
    ng( 1,  0,  2,  6,  2, 12), -- bottom left leg - front
    ng( 2,  6,  4,  4,  2,  8), -- top left leg - front

    ng( 6,  8,  6,  4,  8,  4), -- top mid segment wall

    ng( 6,  0,  0,  4,  8, 10), -- mid wall bottom - side
    ng( 7,  8,  1,  2,  8,  8), -- top small wall - side
    ng( 6,  8,  0,  4,  8,  2), -- top left segment wall - side
    ng( 2,  0,  1, 12,  2,  6), -- bottom left leg - side
    ng( 4,  6,  2,  8,  2,  4), -- top left leg - side
  }
}

local retaining_wall_corner_collision_box = {
  type = "fixed",
  fixed = {
    ng( 0,  0,  4, 10, 16, 12),
    ng( 4,  0,  0, 12, 16, 10),
  }
}

for _,row in ipairs(yatm.colors) do
  local color_basename = row.name
  local color_name = row.description

  minetest.register_node("yatm_foundry:concrete_retaining_wall_" .. color_basename, {
    basename = "yatm_foundry:retaining_wall",
    base_description = "Concrete Retaining Wall",

    description = "Concrete Retaining Wall (" .. color_name .. ")",

    codex_entry_id = "yatm_foundry:concrete_retaining_wall",

    groups = {
      cracky = nokore.dig_class("copper"),
      --
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
    use_texture_alpha = "opaque",

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
    node_box = retaining_wall_nodebox,
    collision_box = retaining_wall_collision_box,
  })

  minetest.register_node("yatm_foundry:concrete_retaining_wall_corner_" .. color_basename, {
    basename = "yatm_foundry:retaining_wall_corner",
    base_description = "Concrete Retaining Wall Corner",

    description = "Concrete Retaining Wall Corner (" .. color_name .. ")",

    codex_entry_id = "yatm_foundry:concrete_retaining_wall_corner",

    groups = {
      cracky = nokore.dig_class("copper"),
      --
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
    use_texture_alpha = "opaque",

    is_ground_content = false,

    sounds = yatm.node_sounds:build("stone"),

    paramtype = "none",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = retaining_wall_corner_nodebox,
    collision_box = retaining_wall_corner_collision_box,
  })
end
