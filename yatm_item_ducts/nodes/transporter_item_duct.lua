local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

colors = yatm_core.list_concat({{"default", "Default"}}, colors)

for _,color_pair in ipairs(colors) do
  local color_basename = color_pair[1]
  local color_name = color_pair[2]

  minetest.register_node("yatm_item_ducts:transporter_item_duct_" .. color_basename, {
    description = "Inserter Item Duct (" .. color_name .. ")",

    groups = { cracky = 1 },

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {
      "yatm_item_duct_" .. color_basename .. "_pipe.on.png"
    },

    item_transport_device = {
      type = "transporter",
      color = color_basename,
    },

    dye_color = color_basename,
  })
end
