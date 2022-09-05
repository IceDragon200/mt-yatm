local mod = yatm_foundry

local groups = {
  cracky = nokore.dig_class("iron"),
  --
  carbon_steel = 1,
  magnetic = 1,
}

minetest.register_node("yatm_foundry:carbon_steel_block", {
  basename = "yatm_foundry:carbon_steel_block",

  description = mod.S("Carbon Steel Block"),

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = groups,

  tiles = {
    "yatm_carbon_steel_block_side.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  is_ground_content = false,
})

minetest.register_node("yatm_foundry:carbon_steel_smooth_block", {
  basename = "yatm_foundry:carbon_steel_smooth_block",

  description = mod.S("Carbon Steel Smooth Block"),

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = groups,

  tiles = {
    "yatm_carbon_steel_block_smooth.side.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  is_ground_content = false,
})

minetest.register_node("yatm_foundry:carbon_steel_base_panel_block", {
  basename = "yatm_foundry:carbon_steel_base_panel_block",

  description = mod.S("Carbon Steel Base Panel Block"),

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = groups,

  tiles = {
    "yatm_carbon_steel_block_base_panel.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  is_ground_content = false,
})

minetest.register_node("yatm_foundry:carbon_steel_plain_panel_block", {
  basename = "yatm_foundry:carbon_steel_plain_panel_block",

  description = mod.S("Carbon Steel Plain Panel Block"),

  codex_entry_id = "yatm_foundry:carbon_steel_block",

  groups = groups,

  tiles = {
    "yatm_carbon_steel_block_plain_panel.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",

  sounds = yatm.node_sounds:build("metal"),

  is_ground_content = false,
})

local node_names =
  {
    ["yatm_foundry:carbon_steel"] = "Carbon Steel",
    ["yatm_foundry:carbon_steel_smooth"] = "Carbon Steel Smooth",
    ["yatm_foundry:carbon_steel_base_panel"] = "Carbon Steel Base Panel",
    ["yatm_foundry:carbon_steel_plain_panel"] = "Cargon Steel Plain Panel",
  }

for base_node_name,base_description in pairs(node_names) do
  local node_def = assert(minetest.registered_nodes[base_node_name .. "_block"])

  yatm.register_decor_nodes(base_node_name, {
    _ = {
      groups = groups,
      use_texture_alpha = "opaque",
      tiles = node_def.tiles,
      sounds = node_def.sounds,
    },
    column = {
      description = mod.S(base_description .. " Column"),
    },
    plate = {
      description = mod.S(base_description .. " Plate"),
    },
    slab = {
      description = mod.S(base_description .. " Slab"),
    },
    stair = {
      description = mod.S(base_description .. " Stair"),
    },
    stair_inner = {
      description = mod.S(base_description .. " Stair (Inner)"),
    },
    stair_outer = {
      description = mod.S(base_description .. " Stair (Outer)"),
    },
  })
end
