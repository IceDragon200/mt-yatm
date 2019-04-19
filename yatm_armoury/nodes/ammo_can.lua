local ItemInterface = assert(yatm.items.ItemInterface)

function get_ammo_can_formspec(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[12,9]" ..
    "list[nodemeta:" .. spos .. ";main;0,0.3;12,4;]" ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";main]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(2,4.85)
  return formspec
end

local item_interface = ItemInterface.new_simple("main")

function item_interface:allow_insert_item(pos, dir, item_stack)
  return yatm_armoury.is_stack_ammunition(item_stack)
end

minetest.register_node("yatm_armoury:ammo_can", {
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

  sounds = default.node_sound_metal_defaults(), -- do we have paper default?

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
    if not yatm_core.is_blank(old_inv_list) then
      local dumped = minetest.deserialize(old_inv_list)
      local list = new_inv:get_list("main")
      list = yatm_item_storage.InventorySerializer.deserialize(dumped, list)
      new_inv:set_list("main", list)
    end
  end,

  preserve_metadata = function (pos, _old_node, _old_meta_table, drops)
    local stack = drops[1]

    local old_meta = minetest.get_meta(pos)
    local new_meta = stack:get_meta()

    local old_inv = old_meta:get_inventory()
    local list = old_inv:get_list("main")

    local dumped = yatm_item_storage.InventorySerializer.serialize(list)

    --print("preserve_metadata", dump(dumped))
    new_meta:set_string("inventory_dump", minetest.serialize(dumped))
    local description = "Ammo Can (" .. yatm_item_storage.InventorySerializer.description(dumped) .. ")"
    new_meta:set_string("description", description)
  end,

  on_blast = function (pos)
    local drops = {}
    default.get_inventory_drops(pos, "main", drops)
    drops[#drops+1] = "default:" .. name
    minetest.remove_node(pos)
    return drops
  end,

  on_rightclick = function (pos, node, clicker)
    minetest.after(0.1, minetest.show_formspec,
      clicker:get_player_name(),
      "yatm_armoury:ammo_can",
      get_ammo_can_formspec(pos))
  end,

  allow_metadata_inventory_move = function (pos, from_list, from_index, to_list, to_index, count, player)
    return 0
  end,

  allow_metadata_inventory_put = function (pos, listname, index, stack, player)
    if listname == "main" then
      if yatm_armoury.is_stack_ammunition(stack) then
        return stack:get_count()
      end
    end
    return 0
  end
})
