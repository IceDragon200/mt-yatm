local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local wood_types = {}

-- Nokore World Tree *

if rawget(_G, "nokore_world_tree_acacia") then
  wood_types.acacia_planks = {
    name = "Acacia Planks",
    tile = "nokore_planks_acacia.png",
  }
end

if rawget(_G, "nokore_world_tree_big_oak") then
  wood_types.big_oak_planks = {
    name = "Big Oak Planks",
    tile = "nokore_planks_big_oak.png",
  }
end

if rawget(_G, "nokore_world_tree_birch") then
  wood_types.birch_planks = {
    name = "Birch Planks",
    tile = "nokore_planks_birch.png",
  }
end

if rawget(_G, "nokore_world_tree_fir") then
  wood_types.fir_planks = {
    name = "Fir Planks",
    tile = "nokore_planks_fir.png",
  }
end

if rawget(_G, "nokore_world_tree_jungle") then
  wood_types.jungle_planks = {
    name = "Jungle Planks",
    tile = "nokore_planks_jungle.png",
  }
end

if rawget(_G, "nokore_world_tree_oak") then
  wood_types.oak_planks = {
    name = "Oak Planks",
    tile = "nokore_planks_oak.png",
  }
end

if rawget(_G, "nokore_world_tree_sakura") then
  wood_types.sakura_planks = {
    name = "Sakura Planks",
    tile = "nokore_planks_sakura.png",
  }
end

if rawget(_G, "nokore_world_tree_spruce") then
  wood_types.spruce_planks = {
    name = "Spruce Planks",
    tile = "nokore_planks_spruce.png",
  }
end

if rawget(_G, "nokore_world_tree_willow") then
  wood_types.willow_planks = {
    name = "Willow Planks",
    tile = "nokore_planks_willow.png",
  }
end

for wood_basename, wood_config in pairs(wood_types) do
  minetest.register_node(":yatm_woodcraft:" .. wood_basename .. "_panel", {
    basename = "yatm_woodcraft:wood_panel",
    base_description = "Wood Panel",

    description = yatm_woodcraft.S(wood_config.name .. " Panel"),

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
