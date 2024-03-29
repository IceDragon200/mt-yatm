local mod = yatm_woodcraft_nokore

local wood_types = {}

-- Nokore World Tree *

if rawget(_G, "nokore_world_tree_acacia") then
  wood_types.acacia_log = {
    name = "Acacia Log",
    default_basename = "acacia",
  }
end

if rawget(_G, "nokore_world_tree_big_oak") then
  wood_types.big_oak_log = {
    name = "Big Oak Log",
    default_basename = "big_oak",
  }
end

if rawget(_G, "nokore_world_tree_birch") then
  wood_types.birch_log = {
    name = "Birch Log",
    default_basename = "birch",
  }
end

if rawget(_G, "nokore_world_tree_fir") then
  wood_types.fir_log = {
    name = "Fir Log",
    default_basename = "fir",
  }
end

if rawget(_G, "nokore_world_tree_jungle") then
  wood_types.jungle_log = {
    name = "Jungle Log",
    default_basename = "jungle",
  }
end

if rawget(_G, "nokore_world_tree_oak") then
  wood_types.oak_log = {
    name = "Oak Log",
    default_basename = "oak",
  }
end

if rawget(_G, "nokore_world_tree_sakura") then
  wood_types.sakura_log = {
    name = "Sakura Log",
    default_basename = "sakura",
  }
end

if rawget(_G, "nokore_world_tree_spruce") then
  wood_types.spruce_log = {
    name = "Spruce Log",
    default_basename = "spruce",
  }
end

if rawget(_G, "nokore_world_tree_willow") then
  wood_types.willow_log = {
    name = "Willow Log",
    default_basename = "willow",
  }
end

for wood_basename, wood_config in pairs(wood_types) do
  local sounds = nokore.node_sounds:build("wood")
  local tiles = {
    "yatm_wood_core_nokore_" .. wood_config.default_basename .. ".top.png",
    "yatm_wood_core_nokore_" .. wood_config.default_basename .. ".top.png",
    "yatm_wood_core_nokore_" .. wood_config.default_basename .. ".side.png",
    "yatm_wood_core_nokore_" .. wood_config.default_basename .. ".side.png",
    "yatm_wood_core_nokore_" .. wood_config.default_basename .. ".side.png",
    "yatm_wood_core_nokore_" .. wood_config.default_basename .. ".side.png",
  }

  minetest.register_node(":yatm_woodcraft:" .. wood_basename .. "_core", {
    basename = "yatm_woodcraft:wood_core",
    base_description = mod.S("Tree Core"),

    description = mod.S(wood_config.name .. " Core"),

    groups = {
      choppy = nokore.dig_class("wme"),
      wood = 1,
    },

    use_texture_alpha = "opaque",
    tiles = tiles,

    sounds = sounds,

    paramtype = "none",
    paramtype2 = "facedir",
  })

  nokore_stairs.build_and_register_nodes(":yatm_woodcraft:" .. wood_basename .. "_core", {
    -- base
    _ = {
      groups = {
        choppy = nokore.dig_class("wme"),
        --
        wood = 1,
      },
      tiles = tiles,
      sounds = sounds,
    },
    column = {
      description = mod.S(wood_config.name .. " Column"),
    },
    plate = false,
    --plate = {
    --  description = mod.S(wood_config.name .. " Plate"),
    --}, -- panels replace these
    slab = {
      description = mod.S(wood_config.name .. " Slab"),
    },
    stair = {
      description = mod.S(wood_config.name .. " Stair"),
    },
    stair_inner = {
      description = mod.S(wood_config.name .. " Stair Inner"),
    },
    stair_outer = {
      description = mod.S(wood_config.name .. " Stair Outer"),
    },
  })
end
