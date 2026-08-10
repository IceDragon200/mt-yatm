local mod = assert(yatm_plastics)

--
-- Plastic Blocks as of 2026-08-06
--
do
  local bases = {
    {"Checker 1x1", "checker_c1x1a", "yatm_plastic_checker_c1x1.png"},
    {"Checker 1x1", "checker_c1x1b", "yatm_plastic_checker_c1x1_alt.png"},
    {"Checker 2x2", "checker_c2x2a", "yatm_plastic_checker_c2x2.png"},
    {"Checker 2x2", "checker_c2x2b", "yatm_plastic_checker_c2x2_alt.png"},
    {"Checker 4x4", "checker_c4x4a", "yatm_plastic_checker_c4x4.png"},
    {"Checker 4x4", "checker_c4x4b", "yatm_plastic_checker_c4x4_alt.png"},
    {"Checker 8x8", "checker_c8x8a", "yatm_plastic_checker_c8x8.png"},
    {"Checker 8x8", "checker_c8x8b", "yatm_plastic_checker_c8x8_alt.png"},
  }

  local inset_types = {
    {"1x2", "1x2"},
    {"Junction", "2468"},
    {"Line", "28"},
    {"2x2", "2x2"},
    {"Tee", "468"},
    {"Corner", "48"},
    {"Cell", "5"},
    {"Cap", "8"},
    {"Arrow Diaganol", "arrow_7"},
    {"Arrow Cardinal", "arrow_8"},
    {"Diamond", "diamond"},
    {"Trim", "trim"},
  }

  local inset_colors = {
    {"Base", "base"},
    {"Cooling", "cooling"},
    {"Heating", "heating"},
    {"Radiating", "radiating"},
    {"Warning", "warning"},
    {"Warning Blue", "warning_blue"},
    {"Warning Red", "warning_red"},
  }

  for _,base in ipairs(bases) do
    local description = base[1]
    local basename = base[2]
    local filename = base[3]
    -- base only registration
    mod:register_node("plastic_panel_" .. basename, {
      description = mod.S("Plastic Panel " .. description),

      groups = {
        cracky = nokore.dig_class("copper"),
        plastic_block = 1,
      },

      tiles = {
        filename,
      },
      is_ground_content = false,

      paramtype = "none",
      paramtype2 = "facedir",
    })

    yatm.register_decor_nodes(mod:make_name("plastic_panel_" .. basename), {
      _ = {
        groups = {
          cracky = nokore.dig_class("copper"),
          plastic_panel = 1,
        },
        use_texture_alpha = "opaque",
        tiles = {
          filename,
        },

        is_ground_content = false,

        -- sounds = yatm.node_sounds:build("stone"),
        -- dye_color = color_basename,
      },
      column = {
        basename = mod:make_name("plastic_panel_column"),
        codex_entry_id = mod:make_name("plastic_panel_column"),
        base_description = "Plastic Panel Column",
        description = mod.S("Plastic Panel Column" .. description),
      },
      plate = {
        basename = mod:make_name("plastic_panel_plate"),
        codex_entry_id = mod:make_name("plastic_panel_plate"),
        base_description = "Plastic Panel Plate",
        description = mod.S("Plastic Panel Plate" .. description),
      },
      slab = {
        basename = mod:make_name("plastic_panel_slab"),
        codex_entry_id = mod:make_name("plastic_panel_slab"),
        base_description = "Plastic Panel Slab",
        description = mod.S("Plastic Panel Slab" .. description),
      },
      stair = {
        basename = mod:make_name("plastic_panel_stair"),
        codex_entry_id = mod:make_name("plastic_panel_stair"),
        base_description = "Plastic Panel Stair",
        description = mod.S("Plastic Panel Stair" .. description),
      },
      stair_inner = {
        basename = mod:make_name("plastic_panel_stair_inner"),
        codex_entry_id = mod:make_name("plastic_panel_stair"),
        base_description = "Plastic Panel Stair (Inner)",
        description = mod.S("Plastic Panel Stair (Inner)" .. description),
      },
      stair_outer = {
        basename = mod:make_name("plastic_panel_stair_outer"),
        codex_entry_id = mod:make_name("plastic_panel_stair"),
        base_description = "Plastic Panel Stair (Outer)",
        description = mod.S("Plastic Panel Stair (Outer)" .. description),
      },
    })

    for _,inset_type in ipairs(inset_types) do
      for _,inset_color in ipairs(inset_colors) do
        local tilename =
          filename
          .. "^yatm_plastic_inset_" .. inset_type[2] .. "_" .. inset_color[2] .. ".png"

        local suffix = basename .. "_" .. inset_type[2] .. "_" .. inset_color[2]
        local suffix_description = description .. " " .. inset_type[1] .. " " .. inset_color[1]

        mod:register_node("plastic_panel_" .. suffix, {
          description = mod.S("Plastic " .. suffix_description),

          groups = {
            cracky = nokore.dig_class("copper"),
            plastic_block = 1,
          },

          tiles = {
            tilename,
          },
          is_ground_content = false,

          paramtype = "none",
          paramtype2 = "facedir",
        })

        yatm.register_decor_nodes(mod:make_name("plastic_panel_" .. suffix), {
          _ = {
            groups = {
              cracky = nokore.dig_class("copper"),
              plastic_panel = 1,
            },
            use_texture_alpha = "opaque",
            tiles = {
              tilename,
            },

            is_ground_content = false,

            -- sounds = yatm.node_sounds:build("stone"),
            -- dye_color = color_basename,
          },
          column = {
            basename = mod:make_name("plastic_panel_column"),
            codex_entry_id = mod:make_name("plastic_panel_column"),
            base_description = "Plastic Panel Column",
            description = mod.S("Plastic Panel Column" .. suffix_description),
          },
          plate = {
            basename = mod:make_name("plastic_panel_plate"),
            codex_entry_id = mod:make_name("plastic_panel_plate"),
            base_description = "Plastic Panel Plate",
            description = mod.S("Plastic Panel Plate" .. suffix_description),
          },
          slab = {
            basename = mod:make_name("plastic_panel_slab"),
            codex_entry_id = mod:make_name("plastic_panel_slab"),
            base_description = "Plastic Panel Slab",
            description = mod.S("Plastic Panel Slab" .. suffix_description),
          },
          stair = {
            basename = mod:make_name("plastic_panel_stair"),
            codex_entry_id = mod:make_name("plastic_panel_stair"),
            base_description = "Plastic Panel Stair",
            description = mod.S("Plastic Panel Stair" .. suffix_description),
          },
          stair_inner = {
            basename = mod:make_name("plastic_panel_stair_inner"),
            codex_entry_id = mod:make_name("plastic_panel_stair"),
            base_description = "Plastic Panel Stair (Inner)",
            description = mod.S("Plastic Panel Stair (Inner)" .. suffix_description),
          },
          stair_outer = {
            basename = mod:make_name("plastic_panel_stair_outer"),
            codex_entry_id = mod:make_name("plastic_panel_stair"),
            base_description = "Plastic Panel Stair (Outer)",
            description = mod.S("Plastic Panel Stair (Outer)" .. suffix_description),
          },
        })
      end
    end
  end
end

--
-- Just some decorative plastic panels, these were the original blocks.
--
core.register_node("yatm_plastics:plastic_panel_plain_block", {
  basename = "yatm_plastics:plastic_panel_plain_block",
  description = mod.S("Plain Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  tiles = {
    "yatm_plastic_panel_plain.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
})

yatm.register_stateful_node("yatm_plastics:plastic_panel_plain_block", {
  basename = "yatm_plastics:plastic_panel_plain_block",
  base_description = mod.S("Plain Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  paramtype = "none",
  paramtype2 = "facedir",
}, {
  cooling = {
    description = "Plain Plastic Panel Block (Cooling Lights)",

    tiles = {"yatm_plastic_panel_plain.cooling.png"}
  },
  heating = {
    description = "Plain Plastic Panel Block (Heating Lights)",

    tiles = {"yatm_plastic_panel_plain.heating.png"}
  },
  radiating = {
    description = "Plain Plastic Panel Block (Radiating Lights)",

    tiles = {"yatm_plastic_panel_plain.radiating.png"}
  },
})

core.register_node("yatm_plastics:plastic_panel_notched_block", {
  basename = "yatm_plastics:plastic_panel_notched_block",
  description = mod.S("Notched Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  tiles = {
    "yatm_plastic_panel_notched.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",
})

yatm.register_stateful_node("yatm_plastics:plastic_panel_notched_block", {
  basename = "yatm_plastics:plastic_panel_notched_block",
  base_description = mod.S("Notched Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  paramtype = "none",
  paramtype2 = "facedir",
}, {
  cooling = {
    description = "Notched Plastic Panel Block (Cooling Lights)",

    tiles = {"yatm_plastic_panel_notched.cooling.png"}
  },
  heating = {
    description = "Notched Plastic Panel Block (Heating Lights)",

    tiles = {"yatm_plastic_panel_notched.heating.png"}
  },
  radiating = {
    description = "Notched Plastic Panel Block (Radiating Lights)",

    tiles = {"yatm_plastic_panel_notched.radiating.png"}
  },
})

core.register_node("yatm_plastics:plastic_panel_hollow_block", {
  basename = "yatm_plastics:plastic_panel_hollow_block",

  description = mod.S("Hollow Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  tiles = {
    "yatm_plastic_panel_hollow.off.png",
  },

  drawtype = "glasslike",

  paramtype = "none",
  paramtype2 = "facedir",
})

yatm.register_stateful_node("yatm_plastics:plastic_panel_hollow_block", {
  basename = "yatm_plastics:plastic_panel_hollow_block",
  base_description = mod.S("Hollow Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  drawtype = "glasslike",

  paramtype = "none",
  paramtype2 = "facedir",
}, {
  cooling = {
    description = "Hollow Plastic Panel Block (Cooling Lights)",

    tiles = {"yatm_plastic_panel_hollow.cooling.png"}
  },
  heating = {
    description = "Hollow Plastic Panel Block (Heating Lights)",

    tiles = {"yatm_plastic_panel_hollow.heating.png"}
  },
  radiating = {
    description = "Hollow Plastic Panel Block (Radiating Lights)",

    tiles = {"yatm_plastic_panel_hollow.radiating.png"}
  },
})


yatm.register_stateful_node("yatm_plastics:plastic_panel_checker_block", {
  basename = "yatm_plastics:plastic_panel_checker_block",
  base_description = mod.S("Checker Plastic Panel Block"),

  groups = {
    cracky = nokore.dig_class("copper"),
    plastic_block = 1,
  },

  drawtype = "glasslike_framed",

  paramtype = "none",
  paramtype2 = "facedir",
}, {
  off = {
    description = "Checker Plastic Panel Block",

    tiles = {
      "yatm_plastic_panel_border.off.png",
      "yatm_plastic_panel_checker.png",
    },
  },

  cooling = {
    description = "Checker Plastic Panel Block (Cooling Lights)",

    tiles = {
      "yatm_plastic_panel_border.cooling.png",
      "yatm_plastic_panel_checker.png",
    },
  },

  heating = {
    description = "Checker Plastic Panel Block (Heating Lights)",

    tiles = {
      "yatm_plastic_panel_border.heating.png",
      "yatm_plastic_panel_checker.png",
    },
  },

  radiating = {
    description = "Checker Plastic Panel Block (Radiating Lights)",

    tiles = {
      "yatm_plastic_panel_border.radiating.png",
      "yatm_plastic_panel_checker.png",
    },
  },
})
