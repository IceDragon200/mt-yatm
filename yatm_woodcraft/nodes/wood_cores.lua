local wood_types = {}

if rawget(_G, "default") then
  wood_types = {
    oak_wood    = {
      name = "Apple Wood",
      default_basename = "oak",
    },
    jungle_wood = {
      name = "Jungle Wood",
      default_basename = "jungle",
    },
    pine_wood   = {
      name = "Pine Wood",
      default_basename = "pine",
    },
    acacia_wood = {
      name = "Acacia Wood",
      default_basename = "acacia",
    },
    aspen_wood  = {
      name = "Aspen Wood",
      default_basename = "aspen",
    },
  }
end

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
  minetest.register_node("yatm_woodcraft:" .. wood_basename .. "_core", {
    basename = "yatm_woodcraft:wood_core",
    base_description = "Tree Core",

    description = wood_config.name .. " Core",

    groups = {
      choppy = 1,
      wood = 1,
    },

    tiles = {
      "yatm_wood_core_" .. wood_config.default_basename .. ".top.png",
      "yatm_wood_core_" .. wood_config.default_basename .. ".top.png",
      "yatm_wood_core_" .. wood_config.default_basename .. ".side.png",
      "yatm_wood_core_" .. wood_config.default_basename .. ".side.png",
      "yatm_wood_core_" .. wood_config.default_basename .. ".side.png",
      "yatm_wood_core_" .. wood_config.default_basename .. ".side.png",
    },

    paramtype = "none",
    paramtype2 = "facedir",
  })
end
