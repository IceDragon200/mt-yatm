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

  minetest.register_craftitem("yatm_mesecon_locks:access_card_" .. color_basename, {
    description = "Access Card (" .. color_name .. ")",

    groups = {
      access_card = 1,
    },

    inventory_image = "yatm_access_cards_" .. color_basename .. "_common.png",
    dye_color = color_basename,

    stack_max = 1,
  })
end
