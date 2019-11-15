--
-- Crafting Table provides access to recipes that have multiple result items,
-- vs normal crafting, examples would include separating a gun from it's magazine
-- for yatm_armoury.
--
-- It can also be coupled with a cardboard box or other compatible inventory to
-- grab items
--
local table_nodebox = {
  type = "fixed",
  fixed = {
    -- TOP
    yatm_core.Cuboid:new( 0,  4,  0, 16, 12, 16):fast_node_box(),
    -- LEGS
    yatm_core.Cuboid:new( 1,  0,  1,  4,  4,  4):fast_node_box(),
    yatm_core.Cuboid:new(11,  0,  1,  4,  4,  4):fast_node_box(),
    yatm_core.Cuboid:new(11,  0, 11,  4,  4,  4):fast_node_box(),
    yatm_core.Cuboid:new( 1,  0, 11,  4,  4,  4):fast_node_box(),
  }
}

local function crafting_table_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("crafting_grid", 9)
  inv:set_size("result_items", 4)
end

minetest.register_node("yatm_woodcraft:crafting_table_wood", {
  basename = "yatm_woodcraft:crafting_table",

  description = "Wood Crafting Table",
  groups = { crafting_table = 1, cracky = 1 },
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

  sounds = default.node_sound_wood_defaults(),

  on_construct = crafting_table_on_construct,
  --on_destruct = crafting_table_on_destruct,

  --allow_metadata_inventory_move = crafting_table_allow_metadata_inventory_move,
  --allow_metadata_inventory_put = crafting_table_allow_metadata_inventory_put,
  --allow_metadata_inventory_take = crafting_table_allow_metadata_inventory_take,

  --on_metadata_inventory_put = crafting_table_on_metadata_inventory_put,
  --on_metadata_inventory_take = crafting_table_on_metadata_inventory_take,
})