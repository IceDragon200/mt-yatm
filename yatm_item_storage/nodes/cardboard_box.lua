local mod = assert(yatm_item_storage)

local is_blank = assert(foundation.com.is_blank)
local ItemInterface = assert(yatm.items.ItemInterface)
local fspec = assert(foundation.com.formspec.api)

local MAIN_INVENTORY_NAME = "main"

function get_cardboard_box_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local formspec =
    yatm.formspec_render_split_inv_panel(user, 4, 5, { bg = "cardboard" }, function (slot, rect)
      if slot == "main_body" then
        return fspec.label(rect.x, rect.y, "Cardboard Box") ..
               fspec.list("nodemeta:" .. spos, MAIN_INVENTORY_NAME, rect.x, rect.y + 0.5, 4, 4)
      elseif slot == "footer" then
        return fspec.list_ring("nodemeta:" .. spos, MAIN_INVENTORY_NAME) ..
               fspec.list_ring("current_player", "main")
      end
      return ""
    end)

  return formspec
end

function get_super_cardboard_box_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local cols = 16
  local rows = 4

  if rawget(_G, "nokore_player_inv") then
    cols = nokore_player_inv.player_hotbar_size
    rows = math.ceil(64 / cols)
  end

  local formspec =
    yatm.formspec_render_split_inv_panel(user, cols, rows + 1, { bg = "cardboard" }, function (slot, rect)
      if slot == "main_body" then
        return fspec.label(rect.x, rect.y, "Cardboard Box") ..
               fspec.list("nodemeta:" .. spos, MAIN_INVENTORY_NAME, rect.x, rect.y + 0.5, cols, rows)
      elseif slot == "footer" then
        return fspec.list_ring("nodemeta:" .. spos, MAIN_INVENTORY_NAME) ..
               fspec.list_ring("current_player", "main")
      end
      return ""
    end)

  return formspec
end

local cardboard_box_item_interface = ItemInterface.new_simple(MAIN_INVENTORY_NAME)

local function cardboard_box_after_place_node(pos, placer, item_stack, pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = item_stack:get_meta()

  local new_inv = new_meta:get_inventory()

  local old_inv_list = old_meta:get_string("inventory_dump")
  if not is_blank(old_inv_list) then
    local dumped = minetest.deserialize(old_inv_list)
    local list = new_inv:get_list(MAIN_INVENTORY_NAME)
    list = yatm.items.InventorySerializer.load_list(dumped, list)
    new_inv:set_list(MAIN_INVENTORY_NAME, list)
  end
end

local function cardboard_box_preserve_metadata(pos, old_node, _old_meta_table, drops)
  local stack = drops[1]

  local old_meta = minetest.get_meta(pos)
  local new_meta = stack:get_meta()

  local old_inv = old_meta:get_inventory()
  local list = old_inv:get_list(MAIN_INVENTORY_NAME)

  local dumped = yatm.items.InventorySerializer.dump_list(list)

  --print("preserve_metadata", dump(dumped))
  new_meta:set_string("inventory_dump", minetest.serialize(dumped))
  local description = minetest.registered_nodes[old_node.name].description .. " (" .. yatm.items.InventorySerializer.description(dumped) .. ")"
  new_meta:set_string("description", description)
end

local function cardboard_box_on_dig(pos, node, puncher)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  if not inv:is_empty("main") then
    return false
  end

  return minetest.node_dig(pos, node, puncher)
end

--- @spec cardboard_box_on_blast(pos: Vector3, intensity: Float): Table
local function cardboard_box_on_blast(pos, _intensity)
  local drops = {}
  foundation.com.get_inventory_drops(pos, MAIN_INVENTORY_NAME, drops)
  table.insert(drops, mod:make_name("cardboard_box"))
  minetest.remove_node(pos)
  return drops
end

--- Super Cardboard Boxes are blast resistant and will not react to being blown up.
---
--- @spec super_cardboard_box_on_blast(pos: Vector3, intensity: Float): Table
local function super_cardboard_box_on_blast(_pos, _intensity)
  return {}
end

minetest.register_node(mod:make_name("cardboard_box"), {
  description = mod.S("Cardboard Box"),

  codex_entry_id = mod:make_name("cardboard_box"),

  groups = {
    snappy = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    --
    cardboard = 1,
    cardboard_box = 1,
    item_interface_in = 1,
    item_interface_out = 1,
  },

  stack_max = 1,

  tiles = {
    "yatm_cardboard_box_top.png",
    "yatm_cardboard_box_bottom.png",
    "yatm_cardboard_box_side.png",
    "yatm_cardboard_box_side.png",
    "yatm_cardboard_box_side.png",
    "yatm_cardboard_box_side.png",
  },

  is_ground_content = false,

  sounds = yatm.node_sounds:build("cardboard"),

  paramtype = "none",
  paramtype2 = "facedir",

  item_interface = cardboard_box_item_interface,

  action_hints = {
    secondary = "inventory",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    inv:set_size(MAIN_INVENTORY_NAME, 4 * 4)
  end,

  after_place_node = cardboard_box_after_place_node,
  preserve_metadata = cardboard_box_preserve_metadata,
  on_dig = cardboard_box_on_dig,
  on_blast = cardboard_box_on_blast,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_item_storage:cardboard_box",
      get_cardboard_box_formspec(pos, user))
  end,
})

minetest.register_node(mod:make_name("super_cardboard_box"), {
  description = mod.S("SUPER Cardboard Box\nFor when a regular one isn't good enough"),

  codex_entry_id = mod:make_name("super_cardboard_box"),

  groups = {
    snappy = nokore.dig_class("wme"),
    oddly_breakable_by_hand = nokore.dig_class("hand"),
    --
    cardboard = 1,
    cardboard_box = 1,
    item_interface_in = 1,
    item_interface_out = 1,
  },

  stack_max = 1,

  tiles = {
    "yatm_super_cardboard_box_top.png",
    "yatm_super_cardboard_box_bottom.png",
    "yatm_super_cardboard_box_side.png",
    "yatm_super_cardboard_box_side.png",
    "yatm_super_cardboard_box_side.png",
    "yatm_super_cardboard_box_side.png",
  },

  is_ground_content = false,

  sounds = yatm.node_sounds:build("cardboard"),

  paramtype = "none",
  paramtype2 = "facedir",

  item_interface = cardboard_box_item_interface,

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    inv:set_size(MAIN_INVENTORY_NAME, 16*4)
  end,

  after_place_node = cardboard_box_after_place_node,
  preserve_metadata = cardboard_box_preserve_metadata,
  on_dig = cardboard_box_on_dig,
  on_blast = super_cardboard_box_on_blast,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_item_storage:super_cardboard_box",
      get_super_cardboard_box_formspec(pos, user)
    )
  end,
})
