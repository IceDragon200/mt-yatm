local colors = {"white", "red", "yellow", "fiber"}
local sizes = {"2x", "4x", "8x"}

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
    if size ~= "2x" and color == "fiber" then
      -- skip it
    else
      minetest.register_node("yatm_decor:warning_stripes_" .. size .. "_" .. color, {
        basename = "yatm_decor:warning_stripes",
        base_description = "Warning Stripes",

        description = "Warning Stripes " .. size .. " (" .. color .. ")",

        groups = {cracky = 1},

        tiles = {
          "yatm_warning_stripes_" .. size .. "_" .. color .. "_15.png",
        },

        paramtype = "light",
        paramtype2 = "facedir",

        place_param2 = 0,
      })

      minetest.register_node("yatm_decor:warning_stripes_slab_" .. size .. "_" .. color, {
        basename = "yatm_decor:warning_stripes_slab",
        base_description = "Warning Stripes Slab",

        description = "Warning Stripes Slab " .. size .. " (" .. color .. ")",

        groups = {cracky = 1},

        tiles = {
          "yatm_warning_stripes_" .. size .. "_" .. color .. "_15.png",
        },

        paramtype = "light",
        paramtype2 = "facedir",

        place_param2 = 0,

        drawtype = "nodebox",
        node_box = slab_nodebox,
      })

      minetest.register_node("yatm_decor:warning_stripes_plate_" .. size .. "_" .. color, {
        basename = "yatm_decor:warning_stripes_plate",
        base_description = "Warning Stripes Panel",

        description = "Warning Stripes Panel " .. size .. " (" .. color .. ")",

        groups = {cracky = 1},

        tiles = {
          "yatm_warning_stripes_" .. size .. "_" .. color .. "_15.png",
        },

        paramtype = "light",
        paramtype2 = "facedir",

        drawtype = "nodebox",
        node_box = plate_nodebox,
      })
    end
  end
end
