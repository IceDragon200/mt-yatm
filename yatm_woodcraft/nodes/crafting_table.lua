--
-- Crafting Table provides access to recipes that have multiple result items,
-- vs normal crafting, examples would include separating a gun from it's magazine
-- for yatm_armoury.
--
-- It can also be coupled with a cardboard box or other compatible inventory to
-- grab items
--
local mod = yatm_woodcraft
local fspec = assert(foundation.com.formspec.api)
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
  assert(user, "expected a player")
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local my_inv_name = "nodemeta:" .. spos

  local cio = fspec.calc_inventory_offset

  return yatm.formspec_render_split_inv_panel(user, 8, 4, { bg = "wood" }, function (loc, rect)
    if loc == "main_body" then
      return "" ..
        fspec.list(my_inv_name, "main", rect.x, rect.y + cio(0), 2, 4) ..
        fspec.list(my_inv_name, "crafting_grid", rect.x + cio(2.5), rect.y + cio(0.5), 3, 3) ..
        fspec.list(my_inv_name, "result_items", rect.x + cio(6), rect.y + cio(1), 2, 2)
    elseif loc == "footer" then
      return fspec.list_ring(my_inv_name, "main") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(my_inv_name, "crafting_grid") ..
        fspec.list_ring("current_player", "main") ..
        fspec.list_ring(my_inv_name, "result_items") ..
        fspec.list_ring("current_player", "main")
    end
    return ""
  end)
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

mod:register_node("crafting_table_wood", {
  basename = "yatm_woodcraft:crafting_table",

  description = mod.S("Wood Crafting Table"),

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
