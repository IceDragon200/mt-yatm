--
-- Healthpacks are blocks that can heal a player entity on right-click.
-- They hold up to 8 charges, and can be restored by using a health pack pouch.
-- Or by crafting an empty pack with 8 pouches in a grid.
--
local itemstack_has_group = assert(foundation.com.itemstack_has_group)
local table_merge = assert(foundation.com.table_merge)

local MAXIMUM_CHARGES = 8
local MP_PER_CHARGE = 2

local nodebox = {
  type = "fixed",
  fixed = {
    {-8/16,-8/16,-6/16,8/16,8/16,6/16}
  }
}

local function recover_mp(entity, amount, reason)
  -- TODO: this ties in with harmonia_mana
  return 0
end

minetest.register_node("yatm_packs:mana_pack_empty", {
  description = "Mana Pack (Empty)",

  groups = {
    snappy = 2,
    choppy = 2,
    oddly_breakable_by_hand = 3,
    mana_pack = 1,
  },

  tiles = {
    "yatm_mana_pack_top.png",
    "yatm_mana_pack_bottom.png",
    "yatm_mana_pack_side.png",
    "yatm_mana_pack_side.png",
    "yatm_mana_pack_back.png",
    "yatm_mana_pack_front_empty.png",
  },

  drawtype = "nodebox",
  node_box = nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
    if itemstack_has_group(itemstack, "mana_pack_pouch") then
      local meta = minetest.get_meta(pos)
      local charges_left = meta:get_int("charges")
      itemstack:take_item(1) -- remove one of the packs
      charges_left = charges_left + 1
      meta:set_int("charges", charges_left)

      local new_node = table_merge(node, { name = "yatm_packs:mana_pack" })
      minetest.swap_node(pos, new_node)
    else
      minetest.chat_send_player(clicker:get_player_name(), "The manapack is empty")
    end
  end,
})

minetest.register_node("yatm_packs:mana_pack", {
  description = "Mana Pack",

  groups = {
    snappy = 2,
    choppy = 2,
    oddly_breakable_by_hand = 3,
    mana_pack = 1,
  },

  tiles = {
    "yatm_mana_pack_top.png",
    "yatm_mana_pack_bottom.png",
    "yatm_mana_pack_side.png",
    "yatm_mana_pack_side.png",
    "yatm_mana_pack_back.png",
    "yatm_mana_pack_front.png",
  },

  drawtype = "nodebox",
  node_box = nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_int("charges", MAXIMUM_CHARGES)
  end,

  on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    local charges_left = meta:get_int("charges")

    if itemstack_has_group(itemstack, "mana_pack_pouch") then
      if charges_left < MAXIMUM_CHARGES then
        itemstack:take_item(1) -- remove one of the packs
        charges_left = charges_left + 1
        meta:set_int("charges", charges_left)
      else
        minetest.chat_send_player(clicker:get_player_name(), "The manapack is full")
      end
    else
      if charges_left > 0 then
        if recover_mp(clicker, MP_PER_CHARGE, "manapack") > 0 then
          charges_left = charges_left - 1
          meta:set_int("charges", charges_left)
          minetest.chat_send_player(clicker:get_player_name(), "There are " .. charges_left .. " charges left")
        else
          minetest.chat_send_player(clicker:get_player_name(), "You are already at max mana")
        end
      else
        minetest.chat_send_player(clicker:get_player_name(), "The manapack is empty")
      end
    end

    if charges_left == 0 then
      local new_node = table_merge(node, { name = "yatm_packs:mana_pack_empty" })
      minetest.swap_node(pos, new_node)
    end

    return itemstack
  end,
})
