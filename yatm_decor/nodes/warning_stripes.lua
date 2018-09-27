local colors = {"white", "red", "yellow", "fiber"}
local sizes = {"2x", "4x", "8x"}

for _,color in ipairs(colors) do
  for _,size in ipairs(sizes) do
    if size ~= "2x" and color == "fiber" then
      -- skip it
    else
      minetest.register_node("yatm_decor:warning_stripes_" .. size .. "_" .. color, {
        description = "Warning Stripes " .. size .. " (" .. color .. ")",
        groups = {cracky = 1},
        tiles = {
          "yatm_warning_stripes_" .. size .. "_" .. color .. "_15.png",
        },
        paramtype = "light",
        paramtype2 = "facedir",
      })
    end
  end
end
