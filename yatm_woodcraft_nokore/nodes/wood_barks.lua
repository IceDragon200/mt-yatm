local Cuboid = yatm_core.Cuboid
local ng = Cuboid.new_fast_node_box

local wood_types = {}

-- Nokore World Tree *

if rawget(_G, "nokore_world_tree_acacia") then
  wood_types.acacia_log = {
    name = "Acacia Log",
    tile = "nokore_log_acacia.png",
  }
end

if rawget(_G, "nokore_world_tree_big_oak") then
  wood_types.big_oak_log = {
    name = "Big Oak Log",
    tile = "nokore_log_big_oak.png",
  }
end

if rawget(_G, "nokore_world_tree_birch") then
  wood_types.birch_log = {
    name = "Birch Log",
    tile = "nokore_log_birch.png",
  }
end

if rawget(_G, "nokore_world_tree_fir") then
  wood_types.fir_log = {
    name = "Fir Log",
    tile = "nokore_log_fir.png",
  }
end

if rawget(_G, "nokore_world_tree_jungle") then
  wood_types.jungle_log = {
    name = "Jungle Log",
    tile = "nokore_log_jungle.png",
  }
end

if rawget(_G, "nokore_world_tree_oak") then
  wood_types.oak_log = {
    name = "Oak Log",
    tile = "nokore_log_oak.png",
  }
end

if rawget(_G, "nokore_world_tree_sakura") then
  wood_types.sakura_log = {
    name = "Sakura Log",
    tile = "nokore_log_sakura.png",
  }
end

if rawget(_G, "nokore_world_tree_spruce") then
  wood_types.spruce_log = {
    name = "Spruce Log",
    tile = "nokore_log_spruce.png",
  }
end

if rawget(_G, "nokore_world_tree_willow") then
  wood_types.willow_log = {
    name = "Willow Log",
    tile = "nokore_log_willow.png",
  }
end

for wood_basename, wood_config in pairs(wood_types) do
  minetest.register_node(":yatm_woodcraft:" .. wood_basename .. "_bark", {
    basename = "yatm_woodcraft:wood_bark",
    base_description = "Tree Bark",

    description = yatm_woodcraft.S(wood_config.name .. " Bark"),

    groups = {
      choppy = 1,
    },

    tiles = {
      wood_config.tile,
    },

    paramtype = "light",
    paramtype2 = "facedir",

    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 2, 16),
      },
    },
  })
end
