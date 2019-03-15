local colors = {
  {"default", "Default"},
  {"tech", "tech"},
}

local variants = {
  {"gold_princess", "Gold Princess"},
  {"gold_queen", "Gold Queen"},
  {"silver_princess", "Silver Princess"},
  {"silver_queen", "Silver Queen"},
  {"worker", "Worker"},
}

for _,variant_pair in ipairs(variants) do
  local variant_basename = variant_pair[1]
  local variant_name = variant_pair[2]
  for _,color_pair in ipairs(colors) do
    local color_basename = color_pair[1]
    local color_name = color_pair[2]
    minetest.register_craftitem("yatm_bees:bee_" .. variant_basename .. "_" .. color_basename, {
      description = variant_name .. " Bee (" .. color_basename .. ")",

      groups = {bee = 1, ["bee_" .. variant_basename] = 1, ["bee_color_" .. color_basename] = 1},

      inventory_image = "yatm_bees_" .. variant_basename .. "_" .. color_basename .. ".png",

      bee = {
        color = color_basename,
        variant = variant_basename,
      },
    })
  end
end
