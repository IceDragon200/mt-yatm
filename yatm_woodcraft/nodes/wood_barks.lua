local wood_types = {
  oak_wood    = {
    name = "Apple Tree",
    default_basename = "tree",
  },
  jungle_wood = {
    name = "Jungle Tree",
    default_basename = "jungletree",
  },
  pine_wood   = {
    name = "Pine Tree",
    default_basename = "pine_tree",
  },
  acacia_wood = {
    name = "Acacia Tree",
    default_basename = "acacia_tree",
  },
  aspen_wood  = {
    name = "Aspen Tree",
    default_basename = "aspen_tree",
  },
}

for wood_basename, wood_config in pairs(wood_types) do
  minetest.register_node("yatm_woodcraft:" .. wood_basename .. "_bark", {
    basename = "yatm_woodcraft:wood_bark",
    base_description = "Tree Bark",

    description = wood_config.name .. " Bark",

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
        yatm_core.Cuboid:new(0, 0, 0, 16, 2, 16):fast_node_box(),
      },
    },
  })
end
