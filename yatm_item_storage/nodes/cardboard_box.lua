local ItemInterface = assert(yatm.items.ItemInterface)

function get_cardboard_box_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "cardboard") ..
    "label[0,0;Cardboard Box]" ..
    "list[nodemeta:" .. spos .. ";main;2,0.5;4,4;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

function get_super_cardboard_box_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[16,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "cardboard") ..
    "label[0,0;SUPER Cardboard Box]" ..
    "list[nodemeta:" .. spos .. ";main;0,0.5;16,4;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(0,4.85)
  return formspec
end

local cardboard_box_item_interface = ItemInterface.new_simple("main")

local function cardboard_box_after_place_node(pos, placer, item_stack, pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = item_stack:get_meta()

  local new_inv = new_meta:get_inventory()

  local old_inv_list = old_meta:get_string("inventory_dump")
  if not yatm_core.is_blank(old_inv_list) then
    local dumped = minetest.deserialize(old_inv_list)
    local list = new_inv:get_list("main")
    list = yatm_item_storage.InventorySerializer.deserialize_list(dumped, list)
    new_inv:set_list("main", list)
  end
end

local function cardboard_box_preserve_metadata(pos, old_node, _old_meta_table, drops)
  local stack = drops[1]

  local old_meta = minetest.get_meta(pos)
  local new_meta = stack:get_meta()

  local old_inv = old_meta:get_inventory()
  local list = old_inv:get_list("main")

  local dumped = yatm_item_storage.InventorySerializer.serialize(list)

  --print("preserve_metadata", dump(dumped))
  new_meta:set_string("inventory_dump", minetest.serialize(dumped))
  local description = minetest.registered_nodes[old_node.name].description .. " (" .. yatm_item_storage.InventorySerializer.description(dumped) .. ")"
  new_meta:set_string("description", description)
end

local function cardboard_box_on_blast(pos)
  local drops = {}
  default.get_inventory_drops(pos, "main", drops)
  drops[#drops+1] = "default:" .. name
  minetest.remove_node(pos)
  return drops
end

minetest.register_node("yatm_item_storage:cardboard_box", {
  description = "Cardboard Box",

  codex_entry_id = "yatm_item_storage:cardboard_box",

  groups = {
    cracky = 1,
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

  sounds = default.node_sound_wood_defaults(), -- do we have paper default?

  paramtype = "light",
  paramtype2 = "facedir",

  item_interface = cardboard_box_item_interface,

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    inv:set_size("main", 4*4)
  end,

  after_place_node = cardboard_box_after_place_node,
  preserve_metadata = cardboard_box_preserve_metadata,
  on_blast = cardboard_box_on_blast,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_item_storage:cardboard_box",
      get_cardboard_box_formspec(pos, user))
  end,
})

minetest.register_node("yatm_item_storage:super_cardboard_box", {
  description = "SUPER Cardboard Box\nFor when a regular one isn't good enough",

  codex_entry_id = "yatm_item_storage:super_cardboard_box",

  groups = {
    cracky = 1,
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

  sounds = default.node_sound_wood_defaults(), -- do we have paper default?

  paramtype = "light",
  paramtype2 = "facedir",

  item_interface = cardboard_box_item_interface,

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    inv:set_size("main", 16*4)
  end,

  after_place_node = cardboard_box_after_place_node,
  preserve_metadata = cardboard_box_preserve_metadata,
  on_blast = cardboard_box_on_blast,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_item_storage:super_cardboard_box",
      get_super_cardboard_box_formspec(pos, user))
  end,
})
