local mod = assert(yatm_security)

local is_blank = assert(foundation.com.is_blank)
local itemstack_is_blank = assert(foundation.com.itemstack_is_blank)
local set_itemstack_meta_description = assert(foundation.com.set_itemstack_meta_description)
local get_itemstack_description = assert(foundation.com.get_itemstack_description)
local fspec = assert(foundation.com.formspec.api)

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

local function locksmiths_table_get_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  assigns.tab = assigns.tab or 1

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "wood" }, function (loc, rect)
    if loc == "main_body" then
      local formspec =
        fspec.tabheader(0, 0, nil, nil, "tab", {"Lock Installation", "Chip Installation", "Key Duplication"}, assigns.tab)

      if assigns.tab == 1 then
        formspec =
          formspec ..
          --
          -- Lock Installation - physical locks
          --
          "label[0,0.5;Lock Installation]" ..
          "label[0,1;Lockable]" ..
          "list[nodemeta:" .. spos .. ";item_lockable;0,1.5;1,1;]" ..
          "label[1.5,1;Lock]" ..
          "list[nodemeta:" .. spos .. ";item_lock;1.5,1.5;1,1;]" ..
          "label[3,1;Key]" ..
          "list[nodemeta:" .. spos .. ";item_key;3,1.5;1,1;]" ..
          "list[nodemeta:" .. spos .. ";item_result;6,1.5;2,1;]" ..
          "listring[nodemeta:" .. spos .. ";item_lockable]" ..
          --
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_lock]" ..
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_key]" ..
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_result]" ..
          "listring[current_player;main]"

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          --
          -- Chip Installation
          --
          "label[0,0.5;Chip Installation]" ..
          "label[0,1;Chippable]" ..
          "list[nodemeta:" .. spos .. ";item_chippable;0,1.5;1,1;]" ..
          "label[1.5,1;Chip]" ..
          "list[nodemeta:" .. spos .. ";item_access_chip;1.5,1.5;1,1;]" ..
          "list[nodemeta:" .. spos .. ";item_chipped_result;7,1.5;1,1;]" ..
          --
          "listring[nodemeta:" .. spos .. ";item_chippable]" ..
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_access_chip]" ..
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_chipped_result]" ..
          "listring[current_player;main]"

      elseif assigns.tab == 3 then
        formspec =
          formspec ..
          --
          -- Key Duplication
          --
          "label[0,0.5;Key Duplication]" ..
          "label[0,1;Source Key]" ..
          "list[nodemeta:" .. spos .. ";item_dupkey_src;0,1.5;1,1;]" ..
          "label[1.5,1;Blank Key]" ..
          "list[nodemeta:" .. spos .. ";item_dupkey_dest;1.5,1.5;1,1;]" ..
          "list[nodemeta:" .. spos .. ";item_dupkey_result;7,1.5;1,1;]" ..
          --
          "listring[nodemeta:" .. spos .. ";item_dupkey_src]" ..
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_dupkey_dest]" ..
          "listring[current_player;main]" ..
          "listring[nodemeta:" .. spos .. ";item_dupkey_result]" ..
          "listring[current_player;main]"
      end

      return formspec
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_player_receive_fields(user, form_name, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  local needs_refresh = false

  if fields["tab"] then
    local tab = tonumber(fields["tab"])
    if tab ~= assigns.tab then
      assigns.tab = tab
      needs_refresh = true
    end
  end

  if needs_refresh then
    local formspec = locksmiths_table_get_formspec(assigns.pos, user, assigns)
    return true, formspec
  else
    return true
  end
end

local function locksmiths_table_on_construct(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  -- Lock Installation
  inv:set_size("item_lockable", 1) -- slot used for placing a 'lockable' item
  inv:set_size("item_lock", 1) -- slot used for the lock
  inv:set_size("item_key", 1) -- slot used for the key to match with the lock
  inv:set_size("item_result", 2) -- slots used to output the result

  -- Chip Installation
  inv:set_size("item_chippable", 1)
  inv:set_size("item_access_chip", 1)
  inv:set_size("item_chipped_result", 1)

  -- Key Duplication
  inv:set_size("item_dupkey_src", 1) -- slot used for duplicating keys (the source)
  inv:set_size("item_dupkey_dest", 1) -- slot used for duplicating keys (the key to copy to)
  inv:set_size("item_dupkey_result", 1) -- slots used to output the key duplication result
end

local function locksmiths_table_on_destruct(pos)
end

local function valid_for_slot(listname, stack)
  if listname == "item_lockable" then
    if yatm_security.is_stack_lockable_object(stack) then
      if is_blank(yatm_security.get_lockable_object_stack_pubkey(stack)) then
        return 1
      end
    end

  elseif listname == "item_lock" then
    if yatm_security.is_stack_lockable_lock(stack) then
      return 1
    end

  elseif listname == "item_key" then
    if yatm_security.is_stack_lockable_blank_key(stack) then
      return 1
    end

  elseif listname == "item_result" then
    return 0 -- cannot put things into the result slot

  elseif listname == "item_chippable" then
    if yatm_security.is_stack_chippable_object(stack) then
      if is_blank(yatm_security.get_chipped_object_stack_pubkey(stack)) then
        return 1
      end
    end

  elseif listname == "item_access_chip" then
    if yatm_security.is_stack_access_chip(stack) then
      return 1
    end

  elseif listname == "item_chipped_result" then
    return 0 -- cannot put things into the result slot

  elseif listname == "item_dupkey_src" then
    if yatm_security.is_stack_lockable_toothed_key(stack) then
      return 1
    end

  elseif listname == "item_dupkey_dest" then
    if yatm_security.is_stack_lockable_blank_key(stack) then
      return 1
    end

  else
    return stack:get_count()
  end
  return 0
end

local function locksmiths_table_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
  --print("locksmiths_table_allow_metadata_inventory_move/7", dump(pos), dump(from_list), dump(from_index), dump(to_list), dump(to_index), dump(count), dump(player))
  return count
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
  return (itemstack_is_blank(result1) and itemstack_is_blank(result1)) or
         (not itemstack_is_blank(result1) and not itemstack_is_blank(result1))
end

local function maybe_craft_lockable(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local lockable = inv:get_stack("item_lockable", 1)
  local lock = inv:get_stack("item_lock", 1)
  local key = inv:get_stack("item_key", 1)

  if can_use_results_slot(inv) then
    if yatm_security.is_stack_lockable_lock(lock) then
      -- lockable style lock installtion
      if  yatm_security.is_stack_lockable_object(lockable) and
          is_blank(yatm_security.get_lockable_object_stack_pubkey(lockable)) and
          yatm_security.is_stack_lockable_blank_key(key) then
        local new_lockable_stack = lockable:peek_item(1)
        local new_key_stack = key:peek_item(1)
        local itemdef = assert(minetest.registered_items[new_key_stack:get_name()])

        new_key_stack:set_name(assert(itemdef.key_states.toothed))
        yatm_security.pair_lockables(new_key_stack, new_lockable_stack)
        inv:set_stack("item_result", 1, new_lockable_stack)
        inv:set_stack("item_result", 2, new_key_stack)
      else
        -- erase the results
        inv:set_stack("item_result", 1, nil)
        inv:set_stack("item_result", 2, nil)
      end
    end
  end
end

local function maybe_craft_chipped(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local chippable = inv:get_stack("item_chippable", 1)
  local chip = inv:get_stack("item_access_chip", 1)

  if yatm_security.is_stack_access_chip(chip) then
    -- access chip based installation
    if yatm_security.is_stack_chippable_object(chippable) and
       is_blank(yatm_security.get_chipped_object_stack_pubkey(chippable)) then
      -- chipped installation doesn't require a key/access card
      -- it's expected that the chip was already programmed beforehand
      -- if not, then you're kinda screwed.

      local new_chipped_stack = chippable:peek_item(1)

      yatm_security.install_chip(new_chipped_stack, chip)

      inv:set_stack("item_chipped_result", 1, new_chipped_stack)
    else
      -- erase the results
      inv:set_stack("item_chipped_result", 1, nil)
    end
  end
end

local function maybe_consume_chipped_ingredients(pos, taken_index)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  inv:set_stack("item_chippable", 1, nil)
  inv:set_stack("item_access_chip", 1, nil)
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
  if itemstack_is_blank(a) and not itemstack_is_blank(b) then
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

local function maybe_craft_duplicate_key(pos)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local src = inv:get_stack("item_dupkey_src", 1)
  local dest = inv:get_stack("item_dupkey_dest", 1)

  -- Check and ensure that we have the right items again
  if yatm_security.is_stack_lockable_toothed_key(src) and yatm_security.is_stack_lockable_blank_key(dest) then
    -- Okay we do, now let's make a duplicate using the dest key
    local dup_stack = dest:peek_item(1)
    local itemdef = assert(minetest.registered_items[dup_stack:get_name()])
    dup_stack:set_name(assert(itemdef.key_states.toothed))
    yatm_security.copy_lockable_key_stack_key(src, dup_stack)
    set_itemstack_meta_description(dup_stack, get_itemstack_description(src))

    inv:set_stack("item_dupkey_result", 1, dup_stack)
  else
    inv:set_stack("item_dupkey_result", 1, nil)
  end
end

local function locksmiths_table_on_metadata_inventory_put(pos, listname, index, stack, player)
  if listname == "item_lockable" or listname == "item_lock" or listname == "item_key" then
    maybe_craft_lockable(pos)

  elseif listname == "item_chippable" or listname == "item_access_chip" then
    maybe_craft_chipped(pos)

  elseif listname == "item_dupkey_src" or listname == "item_dupkey_dest" then
    maybe_craft_duplicate_key(pos)
  end
end

local function locksmiths_table_on_metadata_inventory_take(pos, listname, index, stack, player)
  if listname == "item_lockable" or listname == "item_lock" or listname == "item_key" then
    maybe_craft_lockable(pos)

  elseif listname == "item_result" then
    maybe_consume_lockable_ingredients(pos, index)

  elseif listname == "item_chippable" or listname == "item_access_chip" then
    maybe_craft_chipped(pos)

  elseif listname == "item_chipped_result" then
    maybe_consume_chipped_ingredients(pos, index)

  elseif listname == "item_dupkey_src" or listname == "item_dupkey_dest" then
    maybe_craft_duplicate_key(pos) -- get rid of the result.

  elseif listname == "item_dupkey_result" then
    maybe_consume_dupkey_ingredients(pos, index)
  end
end

local function on_rightclick(pos, node, user, itemstack, pointed_thing)
  local assigns = { pos = pos, node = node }
  local formspec = locksmiths_table_get_formspec(pos, user, assigns)

  local formspec_name = "yatm_security:locksmiths_table:" .. minetest.pos_to_string(pos)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    formspec_name,
    formspec,
    {
      state = assigns,
      on_receive_fields = on_player_receive_fields
    }
  )
end

minetest.register_node("yatm_security:locksmiths_table_wood", {
  basename = "yatm_security:locksmiths_table",

  description = mod.S("Wood Locksmith's Table"),

  codex_entry_id = "yatm_security:locksmiths_table",

  groups = {
    cracky = nokore.dig_class("copper"),
    locksmiths_table = 1,
  },

  use_texture_alpha = "opaque",
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

  sounds = yatm.node_sounds:build("wood"),

  on_construct = locksmiths_table_on_construct,
  on_destruct = locksmiths_table_on_destruct,

  on_rightclick = on_rightclick,

  allow_metadata_inventory_move = locksmiths_table_allow_metadata_inventory_move,
  allow_metadata_inventory_put = locksmiths_table_allow_metadata_inventory_put,
  --allow_metadata_inventory_take = locksmiths_table_allow_metadata_inventory_take,

  on_metadata_inventory_put = locksmiths_table_on_metadata_inventory_put,
  on_metadata_inventory_take = locksmiths_table_on_metadata_inventory_take,
})
