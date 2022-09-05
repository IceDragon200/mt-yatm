local table_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox1
    {-0.4375, -0.5, -0.4375, -0.1875, 0.3125, -0.1875}, -- NodeBox2
    {0.1875, -0.5, -0.4375, 0.4375, 0.3125, -0.1875}, -- NodeBox3
    {0.1875, -0.5, 0.1875, 0.4375, 0.3125, 0.4375}, -- NodeBox4
    {-0.4375, -0.5, 0.1875, -0.1875, 0.3125, 0.4375}, -- NodeBox5
  }
}

local function stonecutters_table_get_formspec(pos, user)
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine") ..
    "label[0,0;Stonecutters' Table]"

  return formspec
end

local function stonecutters_table_configure_inventory(meta)
  local inv = meta:get_inventory()
  inv:set_size("input_slot", 1)
  inv:set_size("processing_slot", 1)
  inv:set_size("output_slot", 1)
end

local function stonecutters_table_on_construct(pos)
  local meta = minetest.get_meta(pos)

  stonecutters_table_configure_inventory(meta)
end

local function stonecutters_table_on_destruct(pos)
end

minetest.register_node("yatm_foundry:stonecutters_table_wood", {
  basename = "yatm_foundry:stonecutters_table",

  description = "Stone Cutter's Table (Wood)",

  codex_entry_id = "yatm_foundry:stonecutters_table_wood",

  groups = {
    snappy = nokore.dig_class("wme"),
    --
    stonecutters_table = 1,
  },

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_stonecutters_table_wood_top.png",
    "yatm_stonecutters_table_wood_bottom.png",
    "yatm_stonecutters_table_wood_side.png",
    "yatm_stonecutters_table_wood_side.png^[transformFX",
    "yatm_stonecutters_table_wood_side.png^[transformFX",
    "yatm_stonecutters_table_wood_side.png"
  },

  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = table_nodebox,

  sounds = yatm.node_sounds:build("wood"),

  on_construct = stonecutters_table_on_construct,
  on_destruct = stonecutters_table_on_destruct,
})
