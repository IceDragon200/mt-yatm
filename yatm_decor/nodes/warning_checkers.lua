local colors = {"white", "red", "yellow"}
local sizes = {"8x"}

local slab_nodebox = {
  type = "fixed",
  fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
}

local plate_nodebox = {
  type = "fixed",
  fixed = {-0.5, -0.5, -0.5, 0.5, (2 / 16.0) - 0.5, 0.5},
}

for _,color in ipairs(colors) do
  for _,size in ipairs(sizes) do
    minetest.register_node("yatm_decor:warning_checkers_" .. size .. "_" .. color, {
      basename = "yatm_decor:warning_checkers",
      base_description = "Warning Checkers",

      description = "Warning Checkers " .. size .. " (" .. color .. ")",
      groups = {cracky = 1},
      tiles = {
        "yatm_warning_checkers_" .. size .. "_" .. color .. "_15.png",
      },
      place_param2 = 0,
      paramtype = "light",
      paramtype2 = "facedir",
    })

    minetest.register_node("yatm_decor:warning_checkers_slab_" .. size .. "_" .. color, {
      basename = "yatm_decor:warning_checkers_slab",
      base_description = "Warning Checkers Slab",

      description = "Warning Checkers Slab " .. size .. " (" .. color .. ")",
      groups = {cracky = 1},
      tiles = {
        "yatm_warning_checkers_" .. size .. "_" .. color .. "_15.png",
      },
      place_param2 = 0,
      paramtype = "light",
      paramtype2 = "facedir",

      drawtype = "nodebox",
      node_box = slab_nodebox,
    })

    minetest.register_node("yatm_decor:warning_checkers_plate_" .. size .. "_" .. color, {
      basename = "yatm_decor:warning_checkers_plate",
      base_description = "Warning Checkers Panel",

      description = "Warning Checkers Panel " .. size .. " (" .. color .. ")",
      groups = {cracky = 1},
      tiles = {
        "yatm_warning_checkers_" .. size .. "_" .. color .. "_15.png",
      },
      paramtype = "light",
      paramtype2 = "facedir",

      drawtype = "nodebox",
      node_box = plate_nodebox,
    })
  end
end
