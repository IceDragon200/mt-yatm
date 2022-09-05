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

for _,row in ipairs(yatm.colors) do
  local color_basename = row.name
  local color_name = row.description

  minetest.register_node("yatm_foundry:lantern_carbon_steel_" .. color_basename, {
    basename = "yatm_foundry:lantern_carbon_steel",

    codex_entry_id = "yatm_foundry:lantern_carbon_steel",

    base_description = yatm_foundry.S("Carbon Steel Lantern"),
    description = yatm_foundry.S(color_name .. " Carbon Steel Lantern"),

    groups = {
      cracky = nokore.dig_class("iron"),
      oddly_breakable_by_hand = nokore.dig_class("hand"),
      --
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
    use_texture_alpha = "opaque",
  })
end
