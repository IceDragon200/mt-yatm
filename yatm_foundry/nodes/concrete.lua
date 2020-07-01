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

local plate_nodebox = {
  type = "fixed",
  fixed = {-0.5, -0.5, -0.5, 0.5, (2 / 16.0) - 0.5, 0.5},
}

local variants = {
  {"bare", "Bare"}, -- Bare is the plain texture
  {"dotted", "Dotted"}, -- Dotted has small 2x2 indents present
  {"circles", "Circles"}, -- Circles have large 4x4 hollow circles
  {"striped", "Striped"}, -- Stripes have just that, stripes
  {"ornated", "Ornated"}, -- A fancy smancy design
  {"tiled", "Tiled"}, -- Has a neat tile texture
  {"meshed", "Meshed"}, -- Has holes in it's tetxure
  {"rosy", "Rosy"}, -- Has a kind of floral texture, maybe
}

for _,pair in ipairs(colors) do
  local color_basename = pair[1]
  local color_name = pair[2]
  for _,variant_pair in ipairs(variants) do
    local variant_basename = variant_pair[1]
    local variant_name = variant_pair[2]

    --[[
    Full Blocks
    ]]
    minetest.register_node("yatm_foundry:concrete_" .. variant_basename .. "_" .. color_basename, {
      basename = "yatm_foundry:concrete",

      base_description = "Concrete",

      description = "Concrete - " .. variant_name .. " (" .. color_name .. ")",

      codex_entry_id = "yatm_foundry:concrete",

      tiles = {"yatm_concrete_" .. variant_basename .. "_" .. color_basename .. "_side.png"},
      groups = {cracky = 1, concrete = 1},
      is_ground_content = false,
      sounds = yatm.node_sounds:build("stone"),
      paramtype = "none",
      paramtype2 = "facedir",
      place_param2 = 0,
      dye_color = color_basename,
    })

    --[[
    Plates
    ]]
    minetest.register_node("yatm_foundry:concrete_plate_" .. variant_basename .. "_" .. color_basename, {
      basename = "yatm_foundry:concrete_plate",
      base_description = "Concrete Panel",

      description = "Concrete Panel - " .. variant_name .. " (" .. color_name .. ")",

      codex_entry_id = "yatm_foundry:concrete_plate",

      tiles = {"yatm_concrete_" .. variant_basename .. "_" .. color_basename .. "_side.png"},
      groups = {cracky = 1, concrete = 1, concrete_plate = 1},
      is_ground_content = false,
      sounds = yatm.node_sounds:build("stone"),
      paramtype = "none",
      paramtype2 = "facedir",
      drawtype = "nodebox",
      node_box = plate_nodebox,
      dye_color = color_basename,

      after_place_node = yatm_core.facedir_wallmount_after_place_node,
    })

    --[[
    Stairs
    ]]
    if stairs then
      stairs.register_stair_and_slab(
        "yatm_foundry_concrete_" .. variant_basename .. "_" .. color_basename,
        "yatm_foundry:concrete_" .. variant_basename .. "_" .. color_basename,
        {cracky = 1, concrete = 1},
        {"yatm_concrete_" .. variant_basename .. "_" .. color_basename .. "_side.png"},
        "Concrete Stair - " .. variant_name .. " (" .. color_name .. ")",
        "Concrete Slab  - " .. variant_name .. " (" .. color_name .. ")",
        yatm.node_sounds:build("stone"),
        false
      )
    else
      minetest.register_node("yatm_foundry:concrete_slab_" .. variant_basename .. "_" .. color_basename, {
        basename = "yatm_foundry:concrete_slab",
        base_description = "Concrete Slab",

        description = "Concrete Slab - " .. variant_name .. " (" .. color_name .. ")",

        codex_entry_id = "yatm_foundry:concrete_slab",

        tiles = {"yatm_concrete_" .. variant_basename .. "_" .. color_basename .. "_side.png"},

        groups = {cracky = 1, concrete = 1},
        is_ground_content = false,
        sounds = yatm.node_sounds:build("stone"),
        paramtype = "none",
        paramtype2 = "facedir",
        place_param2 = 0,
        drawtype = "nodebox",
        node_box = slab_nodebox,
      })
    end
  end

end
