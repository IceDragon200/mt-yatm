local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box

local wood_types = {}

-- Minetest Game's default
if rawget(_G, "default") then
  wood_types = {
    oak_wood    = {
      name = "Apple Tree",
      tile = "default_tree.png",
    },
    jungle_wood = {
      name = "Jungle Tree",
      tile = "default_jungletree.png",
    },
    pine_wood   = {
      name = "Pine Tree",
      tile = "default_pine_tree.png",
    },
    acacia_wood = {
      name = "Acacia Tree",
      tile = "default_acacia_tree.png",
    },
    aspen_wood  = {
      name = "Aspen Tree",
      tile = "default_aspen_tree.png",
    },
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
