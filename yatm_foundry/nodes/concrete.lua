local colors = {
  {"white", "White"}
}

-- If the dye module is available, use the colors from there instead.
if dye then
  colors = dye.dyes
end

local slab_nodebox = {
  type = "fixed",
  fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
}

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]

  --[[
  Full Blocks
  ]]
  minetest.register_node("yatm_foundry:concrete_bare_" .. color_basename, {
    description = "Concrete (" .. color_name .. ")",
    tiles = {"yatm_concrete_bare_" .. color_basename .. "_side.png"},
    groups = {cracky = 1, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  minetest.register_node("yatm_foundry:concrete_dotted_" .. color_basename, {
    description = "Concrete - Dotted (" .. color_name .. ")",
    tiles = {"yatm_concrete_dotted_" .. color_basename .. "_side.png"},
    groups = {cracky = 1, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  minetest.register_node("yatm_foundry:concrete_circles_" .. color_basename, {
    description = "Concrete - Circles (" .. color_name .. ")",
    tiles = {"yatm_concrete_circles_" .. color_basename .. "_side.png"},
    groups = {cracky = 1, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  minetest.register_node("yatm_foundry:concrete_striped_" .. color_basename, {
    description = "Concrete - Striped (" .. color_name .. ")",
    tiles = {"yatm_concrete_striped_" .. color_basename .. "_side.png"},
    groups = {cracky = 1, concrete = 1},
    is_ground_content = false,
    sounds = default.node_sound_stone_defaults(),
    paramtype = "light",
    paramtype2 = "facedir",
    place_param2 = 0,
  })

  --[[
  Stairs
  ]]
  if stairs then
    stairs.register_stair_and_slab(
      "yatm_foundry_concrete_bare_" .. color_basename,
      "yatm_foundry:concrete_bare_" .. color_basename,
      {cracky = 1, concrete = 1},
      {"yatm_concrete_bare_" .. color_basename .. "_side.png"},
      "Concrete Stair (" .. color_name .. ")",
      "Concrete Slab (" .. color_name .. ")",
      default.node_sound_stone_defaults(),
      false
    )

    stairs.register_stair_and_slab(
      "yatm_foundry_concrete_dotted_" .. color_basename,
      "yatm_foundry:concrete_dotted_" .. color_basename,
      {cracky = 1, concrete = 1},
      {"yatm_concrete_dotted_" .. color_basename .. "_side.png"},
      "Concrete Dotted Stair (" .. color_name .. ")",
      "Concrete Dotted Slab (" .. color_name .. ")",
      default.node_sound_stone_defaults(),
      false
    )

    stairs.register_stair_and_slab(
      "yatm_foundry_concrete_circles_" .. color_basename,
      "yatm_foundry:concrete_circles_" .. color_basename,
      {cracky = 1, concrete = 1},
      {"yatm_concrete_circles_" .. color_basename .. "_side.png"},
      "Concrete Dotted Stair (" .. color_name .. ")",
      "Concrete Dotted Slab (" .. color_name .. ")",
      default.node_sound_stone_defaults(),
      false
    )

    stairs.register_stair_and_slab(
      "yatm_foundry_concrete_striped_" .. color_basename,
      "yatm_foundry:concrete_striped_" .. color_basename,
      {cracky = 1, concrete = 1},
      {"yatm_concrete_striped_" .. color_basename .. "_side.png"},
      "Concrete Dotted Stair (" .. color_name .. ")",
      "Concrete Dotted Slab (" .. color_name .. ")",
      default.node_sound_stone_defaults(),
      false
    )
  else
    minetest.register_node("yatm_foundry:concrete_slab_bare_" .. color_basename, {
      description = "Concrete Slab (" .. color_name .. ")",
      tiles = {"yatm_concrete_bare_" .. color_basename .. "_side.png"},
      groups = {cracky = 1, concrete = 1},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      paramtype = "light",
      paramtype2 = "facedir",
      place_param2 = 0,
      drawtype = "nodebox",
      node_box = slab_nodebox,
    })

    minetest.register_node("yatm_foundry:concrete_slab_dotted_" .. color_basename, {
      description = "Concrete Slab - Dotted (" .. color_name .. ")",
      tiles = {"yatm_concrete_dotted_" .. color_basename .. "_side.png"},
      groups = {cracky = 1, concrete = 1},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      paramtype = "light",
      paramtype2 = "facedir",
      place_param2 = 0,
      drawtype = "nodebox",
      node_box = slab_nodebox,
    })

    minetest.register_node("yatm_foundry:concrete_slab_circles_" .. color_basename, {
      description = "Concrete Slab - Circles (" .. color_name .. ")",
      tiles = {"yatm_concrete_circles_" .. color_basename .. "_side.png"},
      groups = {cracky = 1, concrete = 1},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      paramtype = "light",
      paramtype2 = "facedir",
      place_param2 = 0,
      drawtype = "nodebox",
      node_box = slab_nodebox,
    })

    minetest.register_node("yatm_foundry:concrete_slab_striped_" .. color_basename, {
      description = "Concrete Slab - Striped (" .. color_name .. ")",
      tiles = {"yatm_concrete_striped_" .. color_basename .. "_side.png"},
      groups = {cracky = 1, concrete = 1, slab = 1},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      paramtype = "light",
      paramtype2 = "facedir",
      place_param2 = 0,
      drawtype = "nodebox",
      node_box = slab_nodebox,
    })
  end
end
