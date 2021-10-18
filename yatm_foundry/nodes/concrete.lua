local mod = yatm_foundry

local facedir_wallmount_after_place_node = assert(foundation.com.Directions.facedir_wallmount_after_place_node)

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
  {"simple", "Simple"}, -- A simple border
  {"dotted", "Dotted"}, -- Dotted has small 2x2 indents present
  {"circles", "Circles"}, -- Circles have large 4x4 hollow circles
  {"striped", "Striped"}, -- Stripes have just that, stripes
  {"ornated", "Ornated"}, -- A fancy smancy design
  {"tiled", "Tiled"}, -- Has a neat tile texture
  {"meshed", "Meshed"}, -- Has holes in it's tetxure
  {"rosy", "Rosy"}, -- Has a kind of floral texture, maybe
  {"swirl", "Swirl"}, -- A simple swirl pattern
  {"pillar", "Pillar"}, -- A simple pillar like pattern
  {"pillar2", "Pillar (Alt)"}, -- Another pillar like pattern
}

for _,row in ipairs(yatm.colors) do
  local color_basename = row.name
  local color_name = row.description

  for _,variant_pair in ipairs(variants) do
    local variant_basename = variant_pair[1]
    local variant_name = variant_pair[2]

    local variant_description_suffix = " - " .. variant_name .. " (" .. color_name .. ")"

    local tiles = {
      "yatm_concrete_" .. variant_basename .. "_" .. color_basename .. "_side.png"
    }

    local concrete_basename = "yatm_foundry:concrete_" .. variant_basename .. "_" .. color_basename

    minetest.register_node(concrete_basename .. "_block", {
      basename = "yatm_foundry:concrete_block",

      base_description = "Concrete Block",

      description = mod.S("Concrete Block" .. variant_description_suffix),

      codex_entry_id = "yatm_foundry:concrete",

      groups = {
        cracky = 1,
        concrete = 1,
      },

      use_texture_alpha = "opaque",
      tiles = tiles,

      is_ground_content = false,
      sounds = yatm.node_sounds:build("stone"),
      paramtype = "none",
      paramtype2 = "facedir",
      place_param2 = 0,
      dye_color = color_basename,
    })

    yatm.register_decor_nodes(concrete_basename, {
      _ = {
        groups = {
          cracky = 1,
          concrete = 1,
        },
        use_texture_alpha = "opaque",
        tiles = tiles,

        is_ground_content = false,

        sounds = yatm.node_sounds:build("stone"),
        dye_color = color_basename,
      },
      column = {
        basename = "yatm_foundry:concrete_column",
        codex_entry_id = "yatm_foundry:concrete_column",
        base_description = "Concrete Column",
        description = mod.S("Concrete Column" .. variant_description_suffix),
      },
      plate = {
        basename = "yatm_foundry:concrete_plate",
        codex_entry_id = "yatm_foundry:concrete_plate",
        base_description = "Concrete Plate",
        description = mod.S("Concrete Plate" .. variant_description_suffix),
      },
      slab = {
        basename = "yatm_foundry:concrete_slab",
        codex_entry_id = "yatm_foundry:concrete_slab",
        base_description = "Concrete Slab",
        description = mod.S("Concrete Slab" .. variant_description_suffix),
      },
      stair = {
        basename = "yatm_foundry:concrete_stair",
        codex_entry_id = "yatm_foundry:concrete_stair",
        base_description = "Concrete Stair",
        description = mod.S("Concrete Stair" .. variant_description_suffix),
      },
      stair_inner = {
        basename = "yatm_foundry:concrete_stair_inner",
        codex_entry_id = "yatm_foundry:concrete_stair",
        base_description = "Concrete Stair (Inner)",
        description = mod.S("Concrete Stair (Inner)" .. variant_description_suffix),
      },
      stair_outer = {
        basename = "yatm_foundry:concrete_stair_outer",
        codex_entry_id = "yatm_foundry:concrete_stair",
        base_description = "Concrete Stair (Outer)",
        description = mod.S("Concrete Stair (Outer)" .. variant_description_suffix),
      },
    })
  end
end
