local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

-- Default style
--[[local lantern_nodebox = {
  type = "fixed",
  fixed = {
    -- Default
    {-4/16,-8/16,-4/16,4/16,2/16,4/16}, -- Base Body
    {-3/16, 2/16,-3/16,3/16,4/16,3/16},
    {-2/16, 4/16,-2/16,2/16,7/16,2/16},
  }
}]]

-- Fancy style
local fancy_lantern_nodebox = {
  type = "fixed",
  fixed = {
    -- Default
    {-4/16,-8/16,-4/16,4/16,-7/16,4/16}, -- Base Plate
    {-4/16, 1/16,-4/16,4/16,2/16,4/16}, -- Upper Plate
    {-3/16,-7/16,-3/16,3/16,4/16,3/16}, -- Core
    {-2/16, 4/16,-2/16,2/16,7/16,2/16}, -- Top Knob
  }
}

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  minetest.register_node("yatm_foundry:lantern_carbon_steel_" .. color_basename, {
    base_description = "Carbon Steel Lantern",

    codex_entry_id = "yatm_foundry:lantern_carbon_steel",

    description = yatm_foundry.S(color_name .. " Carbon Steel Lantern"),

    groups = {
      oddly_breakable_by_hand = 3,
      cracky = 1,
      lantern = 1,
      carbon_steel = 1,
      metallic = 1,
    },

    is_ground_content = false,

    paramtype = "light",
    sunlight_propagates = false,
    light_source = minetest.LIGHT_MAX,

    drawtype = "nodebox",
    node_box = fancy_lantern_nodebox,
    tiles = {
      "yatm_carbon_steel_lanterns_" .. color_basename .. "_top.png",
      "yatm_carbon_steel_lanterns_" .. color_basename .. "_bottom.png",
      "yatm_carbon_steel_lanterns_" .. color_basename .. "_side.png",
      "yatm_carbon_steel_lanterns_" .. color_basename .. "_side.png",
      "yatm_carbon_steel_lanterns_" .. color_basename .. "_side.png",
      "yatm_carbon_steel_lanterns_" .. color_basename .. "_side.png",
    },
  })
end
