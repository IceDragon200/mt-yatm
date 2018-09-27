local colors = {"white", "red", "yellow"}
local sizes = {"8x"}

for _,color in ipairs(colors) do
  for _,size in ipairs(sizes) do
    minetest.register_node("yatm_decor:warning_checkers_" .. size .. "_" .. color, {
      description = "Warning Checkers " .. size .. " (" .. color .. ")",
      groups = {cracky = 1},
      tiles = {
        "yatm_warning_checkers_" .. size .. "_" .. color .. "_15.png",
      },
      paramtype = "light",
      paramtype2 = "facedir",
    })
  end
end
