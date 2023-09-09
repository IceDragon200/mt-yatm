--
-- Crafting Table provides access to recipes that have multiple result items,
-- vs normal crafting, examples would include separating a gun from it's magazine
-- for yatm_armoury.
--
-- It can also be coupled with a cardboard box or other compatible inventory to
-- grab items
--
local mod = assert(yatm_woodcraft)

local fspec = assert(foundation.com.formspec.api)
local Cuboid = assert(foundation.com.Cuboid)
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
      return ""
        .. fspec.list(my_inv_name, "crafting_grid", rect.x + cio(1.5), rect.y, 3, 3)
        .. fspec.list(my_inv_name, "result_items", rect.x + cio(4.5), rect.y + cio(1), 1, 1)
        .. fspec.list(my_inv_name, "main", rect.x, rect.y + cio(3), 8, 1)
    elseif loc == "footer" then
      return fspec.list_ring(my_inv_name, "main")
        .. fspec.list_ring("current_player", "main")
        .. fspec.list_ring(my_inv_name, "crafting_grid")
        .. fspec.list_ring("current_player", "main")
        .. fspec.list_ring(my_inv_name, "result_items")
        .. fspec.list_ring("current_player", "main")
    end
    return ""
  end)
end

local function on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_size("main", 8)
  inv:set_size("crafting_grid", 9)
  inv:set_size("result_items", 1)
end

local function on_rightclick(pos, node, user)
  local formspec_name = mod:make_name("crafting_table:" .. minetest.pos_to_string(pos))

  minetest.show_formspec(
    user:get_player_name(),
    formspec_name,
    get_crafting_table_formspec(pos, user)
  )
end

local function get_craft_result(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local items = inv:get_list("crafting_grid")

  return minetest.get_craft_result({
    method = "normal",
    width = 3,
    items = items,
  })
end

local function refresh_craft_result(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local output = get_craft_result(pos)

  inv:set_stack("result_items", 1, output.item)
end

local function consume_craft_recipe(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local _output, decremented_input = get_craft_result(pos)

  inv:set_list("crafting_grid", decremented_input.items)
end

local function on_metadata_inventory_move(
  pos,
  from_list,
  from_index,
  to_list,
  to_index,
  count,
  player
)
  if from_list == "result_items" and to_list == "crafting_grid" then
    consume_craft_recipe(pos)
  end

  if from_list == "crafting_grid" or to_list == "crafting_grid" then
    refresh_craft_result(pos)
  end
end

local function on_metadata_inventory_put(
  pos,
  listname,
  index,
  item_stack,
  player
)
  if listname == "crafting_grid" then
    refresh_craft_result(pos)
  end
end

local function on_metadata_inventory_take(
  pos,
  listname,
  index,
  item_stack,
  player
)
  if listname == "crafting_grid" then
    refresh_craft_result(pos)
  elseif listname == "result_items" then
    consume_craft_recipe(pos)
  end
end

mod:register_node("crafting_table_wood", {
  basename = mod:make_name("crafting_table"),

  description = mod.S("Wood Crafting Table"),

  codex_entry_id = mod:make_name("crafting_table"),

  groups = {
    choppy = nokore.dig_class("wme"),
    crafting_table = 1,
  },

  tiles = {
    "yatm_crafting_table_top.png",
    "yatm_crafting_table_bottom.png",
    "yatm_crafting_table_side.png",
    "yatm_crafting_table_side.png^[transformFX",
    "yatm_crafting_table_side.png^[transformFX",
    "yatm_crafting_table_side.png"
  },
  paramtype = "none",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = table_nodebox,

  sounds = yatm.node_sounds:build("wood"),

  on_construct = on_construct,
  on_rightclick = on_rightclick,

  on_metadata_inventory_move = on_metadata_inventory_move,
  on_metadata_inventory_put = on_metadata_inventory_put,
  on_metadata_inventory_take = on_metadata_inventory_take,
})
