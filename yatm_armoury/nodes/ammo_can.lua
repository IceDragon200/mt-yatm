local is_blank = assert(foundation.com.is_blank)
local ItemInterface = assert(yatm.items.ItemInterface)
local fspec = assert(foundation.com.formspec.api)
local is_stack_cartridge = assert(yatm_armoury.is_stack_cartridge)
local InventorySerializer = assert(foundation.com.InventorySerializer)

function get_ammo_can_formspec(pos, entity)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local hotbar_size = yatm.get_player_hotbar_size(entity)

  local w = math.max(12, hotbar_size)
  local h = 10

  local formspec =
    fspec.size(w, h) ..
    yatm.formspec_bg_for_player(entity:get_player_name(), "default") ..
    fspec.list("nodemeta:"..spos, "main", (w - 12) / 2, 0.3, 12, 4) ..
    yatm.player_inventory_lists_fragment(entity, (w - hotbar_size) / 2, 5.85) ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]"

  return formspec
end

local item_interface = ItemInterface.new_simple("main")

function item_interface:allow_insert_item(pos, dir, item_stack)
  return is_stack_cartridge(item_stack)
end

minetest.register_node("yatm_armoury:ammo_can", {
  codex_entry_id = "yatm_armoury:ammo_can",

  basename = "yatm_armoury:ammo_can",

  description = "Ammo Can",

  groups = {
    cracky = 1,
    ammo_can = 1,
    item_interface_in = 1,
    item_interface_out = 1,
  },

  stack_max = 1,

  tiles = {
    "yatm_ammo_can_top.png",
    "yatm_ammo_can_bottom.png",
    "yatm_ammo_can_side.png",
    "yatm_ammo_can_side.png^[transformFX",
    "yatm_ammo_can_back.png",
    "yatm_ammo_can_front.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {(2 / 16.0) - 0.5, -0.5, -0.5, (14 / 16.0) - 0.5, (13 / 16.0) - 0.5, 0.5},
    },
  },

  is_ground_content = false,

  sounds = yatm.node_sounds:build("metal"),

  paramtype = "light",
  paramtype2 = "facedir",

  item_interface = item_interface,

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    inv:set_size("main", 12*4)
  end,

  after_place_node = function (pos, placer, item_stack, pointed_thing)
    local new_meta = minetest.get_meta(pos)
    local old_meta = item_stack:get_meta()

    local new_inv = new_meta:get_inventory()

    local old_inv_list = old_meta:get_string("inventory_dump")
    if not is_blank(old_inv_list) then
      local dumped = minetest.deserialize(old_inv_list)
      local list = new_inv:get_list("main")
      list = InventorySerializer.deserialize_list(dumped, list)
      new_inv:set_list("main", list)
    end
  end,

  preserve_metadata = function (pos, _old_node, _old_meta_table, drops)
    local stack = drops[1]

    local old_meta = minetest.get_meta(pos)
    local new_meta = stack:get_meta()

    local old_inv = old_meta:get_inventory()
    local list = old_inv:get_list("main")

    local dumped = InventorySerializer.serialize(list)

    --print("preserve_metadata", dump(dumped))
    new_meta:set_string("inventory_dump", minetest.serialize(dumped))
    local description = "Ammo Can (" .. InventorySerializer.description(dumped) .. ")"
    new_meta:set_string("description", description)
  end,

  on_blast = function (pos)
    local drops = {}
    drops[1] = "default:" .. name
    foundation.com.get_inventory_drops(pos, "main", drops)
    minetest.remove_node(pos)
    return drops
  end,

  on_rightclick = function (pos, node, clicker)
    minetest.show_formspec(
      clicker:get_player_name(),
      "yatm_armoury:ammo_can",
      get_ammo_can_formspec(pos, clicker)
    )
  end,

  allow_metadata_inventory_move = function (pos, from_list, from_index, to_list, to_index, count, player)
    return 0
  end,

  allow_metadata_inventory_put = function (pos, listname, index, stack, player)
    if listname == "main" then
      if is_stack_cartridge(stack) then
        return stack:get_count()
      end
    end
    return 0
  end
})
