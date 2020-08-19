--
-- Crafting Table provides access to recipes that have multiple result items,
-- vs normal crafting, examples would include separating a gun from it's magazine
-- for yatm_armoury.
--
-- It can also be coupled with a cardboard box or other compatible inventory to
-- grab items
--
local Cuboid = yatm_core.Cuboid
local ng = Cuboid.new_fast_node_box

local table_nodebox = {
  type = "fixed",
  fixed = {
    -- TOP
    ng( 0,  4,  0, 16, 12, 16),
    -- LEGS
    ng( 1,  0,  1,  4,  4,  4),
    ng(11,  0,  1,  4,  4,  4),
    ng(11,  0, 11,  4,  4,  4),
    ng( 1,  0, 11,  4,  4,  4),
  }
}

local function get_crafting_table_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "wood") ..
    "label[0,0;Crafting Table]" ..
    "list[nodemeta:" .. spos .. ";main;0,0.5;2,4;]" ..
    "list[nodemeta:" .. spos .. ";crafting_grid;2.5,1.0;3,3;]" ..
    "list[nodemeta:" .. spos .. ";result_items;6,1.5;2,2;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";crafting_grid]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";result_items]" ..
    "listring[current_player;main]"

  return formspec
end

local function crafting_table_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("main", 8)
  inv:set_size("crafting_grid", 9)
  inv:set_size("result_items", 4)
end

local function crafting_table_on_rightclick(pos, node, user)
  local formspec_name = "yatm_woodcraft:crafting_table_formspec:" .. minetest.pos_to_string(pos)

  minetest.show_formspec(
    user:get_player_name(),
    formspec_name,
    get_crafting_table_formspec(pos, user)
  )
end

minetest.register_node("yatm_woodcraft:crafting_table_wood", {
  basename = "yatm_woodcraft:crafting_table",

  description = "Wood Crafting Table",

  codex_entry_id = "yatm_woodcraft:crafting_table",

  groups = {
    crafting_table = 1,
    cracky = 1,
  },

  tiles = {
    "yatm_crafting_table_top.png",
    "yatm_crafting_table_bottom.png",
    "yatm_crafting_table_side.png",
    "yatm_crafting_table_side.png^[transformFX",
    "yatm_crafting_table_side.png^[transformFX",
    "yatm_crafting_table_side.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = table_nodebox,

  sounds = yatm.node_sounds:build("wood"),

  on_construct = crafting_table_on_construct,
  --on_destruct = crafting_table_on_destruct,

  on_rightclick = crafting_table_on_rightclick,
  --allow_metadata_inventory_move = crafting_table_allow_metadata_inventory_move,
  --allow_metadata_inventory_put = crafting_table_allow_metadata_inventory_put,
  --allow_metadata_inventory_take = crafting_table_allow_metadata_inventory_take,

  --on_metadata_inventory_put = crafting_table_on_metadata_inventory_put,
  --on_metadata_inventory_take = crafting_table_on_metadata_inventory_take,
})
