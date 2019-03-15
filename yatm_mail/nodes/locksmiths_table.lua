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

local locksmiths_table_form = yatm_core.UI.Form:new()
locksmiths_table_form:set_size(8, 8.5)
locksmiths_table_form:new_label(0, 0, "Locksmith's Table")
locksmiths_table_form:new_label(0, 0.5, "Lock Installation")
locksmiths_table_form:new_list("context", "item_lockable", 0, 1.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_lock", 1, 1.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_key", 2, 1.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_result", 6, 1.0, 2, 1, "")
locksmiths_table_form:new_label(0, 2.5, "Key Duplication")
locksmiths_table_form:new_list("context", "item_dupkey_src", 0, 3.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_dupkey_dest", 1, 3.0, 1, 1, "")
locksmiths_table_form:new_list("context", "item_dupkey_result", 6, 3.0, 1, 1, "")
locksmiths_table_form:new_list("current_player", "main", 0, 4.25, 8, 1, "")
locksmiths_table_form:new_list("current_player", "main", 0, 5.5, 8, 3, 8)
locksmiths_table_form:new_list_ring("context", "item_lockable")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_lock")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_key")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_result")
locksmiths_table_form:new_list_ring("current_player", "main")

locksmiths_table_form:new_list_ring("context", "item_dupkey_src")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_dupkey_dest")
locksmiths_table_form:new_list_ring("current_player", "main")
locksmiths_table_form:new_list_ring("context", "item_dupkey_result")
locksmiths_table_form:new_list_ring("current_player", "main")

local function locksmiths_table_get_formspec()
  local formspec =
    default.gui_bg ..
    default.gui_bg_img ..
    default.gui_slots ..
    locksmiths_table_form:to_formspec() ..
    default.get_hotbar_bg(0, 4.25)
  return formspec
end

local function locksmiths_table_configure_inventory(meta)
  local inv = meta:get_inventory()
  inv:set_size("item_lockable", 1) -- slot used for placing a 'lockable' item
  inv:set_size("item_lock", 1) -- slot used for the lock
  inv:set_size("item_key", 1) -- slot used for the key to match with the lock
  inv:set_size("item_result", 2) -- slots used to output the result
  inv:set_size("item_dupkey_src", 1) -- slot used for duplicating keys (the source)
  inv:set_size("item_dupkey_dest", 1) -- slot used for duplicating keys (the key to copy to)
  inv:set_size("item_dupkey_result", 1) -- slots used to output the key duplication result
end

local function locksmiths_table_initialize_formspec(meta)
  meta:set_string("formspec", locksmiths_table_get_formspec())
end

local function locksmiths_table_on_construct(pos)
  local meta = minetest.get_meta(pos)

  locksmiths_table_configure_inventory(meta)
  locksmiths_table_initialize_formspec(meta)
end

local function locksmiths_table_on_destruct(pos)
end

local function valid_for_slot(listname, stack)
  if listname == "item_lockable" then
    if yatm_mail.is_stack_lockable_object(stack) then
      if yatm_core.is_blank(yatm_mail.get_lockable_object_stack_key(stack)) then
        return 1
      end
    end
  elseif listname == "item_lock" then
    if yatm_mail.is_stack_lockable_lock(stack) then
      return 1
    end
  elseif listname == "item_key" then
    if yatm_mail.is_stack_lockable_blank_key(stack) then
      return 1
    end
  elseif listname == "item_dupkey_src" then
    if yatm_mail.is_stack_lockable_toothed_key(stack) then
      return 1
    end
  elseif listname == "item_dupkey_dest" then
    if yatm_mail.is_stack_lockable_blank_key(stack) then
      return 1
    end
  elseif listname == "item_result" then
    return 0 -- cannot put things into the result slot
  else
    return stack:get_count()
  end
  return 0
end

local function locksmiths_table_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  --print("locksmiths_table_allow_metadata_inventory_move/7", dump(pos), dump(from_list), dump(from_index), dump(to_list), dump(to_index), dump(count), dump(player))
  return valid_for_slot(to_list, stack)
end

local function locksmiths_table_allow_metadata_inventory_put(pos, listname, index, stack, player)
  --print("locksmiths_table_allow_metadata_inventory_put/5", dump(pos), dump(listname), dump(index), dump(stack), dump(player))
  return valid_for_slot(listname, stack)
end

local function locksmiths_table_allow_metadata_inventory_take(pos, listname, index, stack, player)
  --print("locksmiths_table_allow_metadata_inventory_take/5", dump(pos), dump(listname), dump(index), dump(stack), dump(player))
  if stack then
    return stack:get_count()
  end
  return 0
end

local function can_use_results_slot(inv)
  local result1 = inv:get_stack("item_result", 1)
  local result2 = inv:get_stack("item_result", 2)

  -- Either both slots MUST be empty, or both MUST be occupied
  return (yatm_core.itemstack_is_blank(result1) and yatm_core.itemstack_is_blank(result1)) or
         (not yatm_core.itemstack_is_blank(result1) and not yatm_core.itemstack_is_blank(result1))
end

local function maybe_craft_lockable(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local lockable = inv:get_stack("item_lockable", 1)
  local lock = inv:get_stack("item_lock", 1)
  local key = inv:get_stack("item_key", 1)

  if can_use_results_slot(inv) then
    if  yatm_mail.is_stack_lockable_object(lockable) and
        yatm_core.is_blank(yatm_mail.get_lockable_object_stack_key(lockable)) and
        yatm_mail.is_stack_lockable_lock(lock) and
        yatm_mail.is_stack_lockable_blank_key(key) then
      local new_lockable_stack = lockable:peek_item(1)
      local new_key_stack = key:peek_item(1)
      local itemdef = assert(minetest.registered_items[new_key_stack:get_name()])
      new_key_stack:set_name(assert(itemdef.key_states.toothed))
      yatm_mail.pair_lockables(new_key_stack, new_lockable_stack)
      inv:set_stack("item_result", 1, new_lockable_stack)
      inv:set_stack("item_result", 2, new_key_stack)
    else
      -- erase the results
      inv:set_stack("item_result", 1, nil)
      inv:set_stack("item_result", 2, nil)
    end
  end
end

local function maybe_consume_lockable_ingredients(pos, taken_index)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local other_index = 0
  if taken_index == 1 then
    other_index = 2
  else
    other_index = 1
  end
  local a = inv:get_stack("item_result", taken_index)
  local b = inv:get_stack("item_result", other_index)

  -- if only one result was removed and the other still exists, consume the ingredients
  if yatm_core.itemstack_is_blank(a) and not yatm_core.itemstack_is_blank(b) then
    inv:set_stack("item_lockable", 1, nil)
    inv:set_stack("item_lock", 1, nil)
    inv:set_stack("item_key", 1, nil)
  end
end

local function maybe_consume_dupkey_ingredients(pos, taken_index)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  inv:set_stack("item_dupkey_dest", 1, nil)
end

local function maybe_duplicate_key(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local src = inv:get_stack("item_dupkey_src", 1)
  local dest = inv:get_stack("item_dupkey_dest", 1)

  -- Check and ensure that we have the right items again
  if yatm_mail.is_stack_lockable_toothed_key(src) and yatm_mail.is_stack_lockable_blank_key(dest) then
    -- Okay we do, now let's make a duplicate using the dest key
    local dup_stack = dest:peek_item(1)
    local itemdef = assert(minetest.registered_items[dup_stack:get_name()])
    dup_stack:set_name(assert(itemdef.key_states.toothed))
    yatm_mail.copy_lockable_key_stack_key(src, dup_stack)
    yatm_core.set_itemstack_meta_description(dup_stack,
      "Duplicate of " .. yatm_core.get_itemstack_description(src))

    inv:set_stack("item_dupkey_result", 1, dup_stack)
  else
    inv:set_stack("item_dupkey_result", 1, nil)
  end
end

local function locksmiths_table_on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "item_lockable" or listname == "item_lock" or listname == "item_key" then
    maybe_craft_lockable(pos)
  elseif listname == "item_dupkey_src" or listname == "item_dupkey_dest" then
    maybe_duplicate_key(pos)
  end
end

local function locksmiths_table_on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "item_lockable" or listname == "item_lock" or listname == "item_key" then
    maybe_craft_lockable(pos)
  elseif listname == "item_dupkey_src" or listname == "item_dupkey_dest" then
    maybe_duplicate_key(pos) -- get rid of the result.
  elseif listname == "item_result" then
    maybe_consume_lockable_ingredients(pos, index)
  elseif listname == "item_dupkey_result" then
    maybe_consume_dupkey_ingredients(pos, index)
  end
end

minetest.register_node("yatm_mail:locksmiths_table_wood", {
  description = "Wood Locksmiths Table",
  groups = { locksmiths_table = 1, cracky = 1 },
  tiles = {
    "yatm_locksmiths_table_wood_top.png",
    "yatm_locksmiths_table_wood_bottom.png",
    "yatm_locksmiths_table_wood_side.png",
    "yatm_locksmiths_table_wood_side.png^[transformFX",
    "yatm_locksmiths_table_wood_side.png^[transformFX",
    "yatm_locksmiths_table_wood_side.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = table_nodebox,

  sounds = default.node_sound_wood_defaults(),

  on_construct = locksmiths_table_on_construct,
  on_destruct = locksmiths_table_on_destruct,

  allow_metadata_inventory_move = locksmiths_table_allow_metadata_inventory_move,
  allow_metadata_inventory_put = locksmiths_table_allow_metadata_inventory_put,
  --allow_metadata_inventory_take = locksmiths_table_allow_metadata_inventory_take,

  on_metadata_inventory_put = locksmiths_table_on_metadata_inventory_put,
  on_metadata_inventory_take = locksmiths_table_on_metadata_inventory_take,
})
