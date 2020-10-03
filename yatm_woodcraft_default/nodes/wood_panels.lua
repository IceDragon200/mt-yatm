local Cuboid = yatm_core.Cuboid
local ng = Cuboid.new_fast_node_box

local wood_types = {}

-- Minetest Game's default
if rawget(_G, "default") then
  wood_types = {
    oak_wood    = {
      name = "Apple Wood",
      tile = "default_wood.png",
    },
    jungle_wood = {
      name = "Jungle Wood",
      tile = "default_junglewood.png",
    },
    pine_wood   = {
      name = "Pine Wood",
      tile = "default_pine_wood.png",
    },
    acacia_wood = {
      name = "Acacia Wood",
      tile = "default_acacia_wood.png",
    },
    aspen_wood  = {
      name = "Aspen Wood",
      tile = "default_aspen_wood.png",
    },
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
