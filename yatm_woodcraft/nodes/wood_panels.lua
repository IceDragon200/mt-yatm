local Cuboid = yatm_core.Cuboid
local ng = Cuboid.new_fast_node_box

local wood_types = {
  oak_wood    = {
    name = "Apple Wood",
    default_basename = "wood",
  },
  jungle_wood = {
    name = "Jungle Wood",
    default_basename = "junglewood",
  },
  pine_wood   = {
    name = "Pine Wood",
    default_basename = "pine_wood",
  },
  acacia_wood = {
    name = "Acacia Wood",
    default_basename = "acacia_wood",
  },
  aspen_wood  = {
    name = "Aspen Wood",
    default_basename = "aspen_wood",
  },
}

for wood_basename, wood_config in pairs(wood_types) do
  minetest.register_node("yatm_woodcraft:" .. wood_basename .. "_panel", {
    basename = "yatm_woodcraft:wood_panel",
    base_description = "Wood Panel",

    description = wood_config.name .. " Panel",

    groups = {
      choppy = 1,
    },

    tiles = {
      "default_" .. wood_config.default_basename .. ".png"
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
