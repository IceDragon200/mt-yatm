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

  minetest.register_node("yatm_foundry:concrete_bare_" .. color_basename, {
    description = "Concrete (" .. color_name .. ")",
    tiles = {"yatm_concrete_bare_" .. color_basename .. "_side.png"},
    groups = {cracky = 3, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  minetest.register_node("yatm_foundry:concrete_dotted_" .. color_basename, {
    description = "Concrete - Dotted (" .. color_name .. ")",
    tiles = {"yatm_concrete_dotted_" .. color_basename .. "_side.png"},
    groups = {cracky = 3, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  minetest.register_node("yatm_foundry:concrete_circles_" .. color_basename, {
    description = "Concrete - Circles (" .. color_name .. ")",
    tiles = {"yatm_concrete_circles_" .. color_basename .. "_side.png"},
    groups = {cracky = 3, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  minetest.register_node("yatm_foundry:concrete_striped_" .. color_basename, {
    description = "Concrete - Striped (" .. color_name .. ")",
    tiles = {"yatm_concrete_striped_" .. color_basename .. "_side.png"},
    groups = {cracky = 3, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })
end
