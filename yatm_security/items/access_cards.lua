if not yatm_data_logic then
  return
end

--
-- Access Cards are the Data equivalent of keys
-- Their corresponding lock is formed from an Access Chip
-- Unlike Keys and Locks however, they must be paired before hand in a 'Programmer's Table'
--
local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

for _,color in pairs(colors) do
  local color_basename = color[1]
  local color_name = color[2]

  minetest.register_craftitem("yatm_security:access_card_" .. color_basename, {
    basename = "yatm_security:access_card",
    base_description = "Access Card",

    description = "Access Card (" .. color_name .. ")",

    groups = {
      access_card = 1,
    },

    inventory_image = "yatm_access_cards_" .. color_basename .. "_common.png",
    dye_color = color_basename,

    stack_max = 1,
  })
end
