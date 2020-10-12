if not foundation.is_module_present("nokore_chest") then
  return
end

local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  nokore_chest:register_chest("yatm_foundry:chest_carbon_steel_" .. color_basename, {
    codex_entry_id = "yatm_foundry:chest_carbon_steel",

    description = yatm_foundry.S(color_name .. " Carbon Steel Chest"),

    groups = {
      cracky = 1,
      chest = 1,
      carbon_steel = 1,
      metallic = 1,
    },

    tiles = {
      "yatm_carbon_steel_chests_" .. color_basename .. "_top.png",
      "yatm_carbon_steel_chests_" .. color_basename .. "_bottom.png",
      "yatm_carbon_steel_chests_" .. color_basename .. "_side.png",
      "yatm_carbon_steel_chests_" .. color_basename .. "_side.png",
      --"yatm_carbon_steel_chests_" .. color_basename .. "_back.png",
      "yatm_carbon_steel_chests_" .. color_basename .. "_front.png",
      --"yatm_carbon_steel_chests_" .. color_basename .. "_inside.png",
      "yatm_carbon_steel_chest_inside.png",
    },
  })
end
