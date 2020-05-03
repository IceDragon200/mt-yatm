local wood_types = {
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
