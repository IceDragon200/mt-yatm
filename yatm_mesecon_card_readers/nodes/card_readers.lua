local reader_node_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new( 0,  0, 13, 16, 16, 3):fast_node_box(),
  }
}

local function card_reader_on_construct(pos)
  local meta = minetest.get_meta(pos)

  local inv = meta:get_inventory()

  inv:set_size("access_card_slot", 1)
end

local function card_reader_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()

  yatm_security.copy_chipped_object(old_meta, new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
end

local function card_reader_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_security.copy_chipped_object(assert(old_meta), new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
  new_meta:set_string("infotext", new_meta:get_string("description"))
end

local function reader_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
  local nodedef = minetest.registered_nodes[node.name]

  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  local access_card = inv:get_stack("access_card_slot", 1)

  if access_card:is_empty() then
    if not itemstack:is_empty() then
      local item = itemstack:get_definition()
      if yatm_core.groups.has_group(item, 'access_card') then
        local leftover = inv:add_item("access_card_slot", itemstack)
        if leftover:is_empty() then
          -- take the access card away from player
          itemstack:take_item(1)

          if nodedef.on_access_card_inserted then
            nodedef.on_access_card_inserted(pos, node, inv:get_stack("access_card_slot", 1))
          end
        end
      end
    end
  else
    if itemstack:is_empty() then
      local leftover = itemstack:add_item(access_card)
      if leftover:is_empty() then
        inv:remove_item("access_card_slot", access_card)

        if nodedef.on_access_card_removed then
          nodedef.on_access_card_removed(pos, node, access_card)
        end
      end
    end
  end
end

local function reader_on_dig(pos, node, digger)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local access_card = inv:get_stack("access_card_slot", 1)
  if not access_card:is_empty() then
    return false
  end
  return minetest.node_dig(pos, node, digger)
end

yatm.register_stateful_node("yatm_mesecon_card_readers:mesecon_card_reader", {
  basename = "yatm_mesecon_card_readers:mesecon_card_reader",

  description = "Card Reader (Mesecons)",

  drop = "yatm_mesecon_card_readers:mesecon_card_reader_off",

  groups = {
    cracky = 1,
    chippable_object = 1,
    mesecon_needs_receiver = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = yatm.node_sounds:build("metal"),

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = reader_node_box,

  on_construct = card_reader_on_construct,

  preserve_metadata = card_reader_preserve_metadata,
  after_place_node = card_reader_after_place_node,

  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  on_rightclick = reader_on_rightclick,

  on_dig = reader_on_dig,
}, {
  off = {
    tiles = {
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_common.back.off.png",
      "yatm_card_reader_reader.front.off.png",
    },

    mesecon = {
      receptor = {
        state = mesecon.state.off,
        rules = mesecon.rules.buttonlike_get,
      }
    },

    on_access_card_inserted = function (pos, node, access_card)
      local new_node = { name = node.name, param1 = node.param1, param2 = node.param2 }
      if yatm_security.is_chipped_node(pos) then
        if yatm_security.is_stack_an_access_card_for_chipped_node(access_card, pos) then
          new_node.name = "yatm_mesecon_card_readers:mesecon_card_reader_on"
          mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(new_node))
        else
          new_node.name = "yatm_mesecon_card_readers:mesecon_card_reader_error"
        end
      else
        -- if the swiper isn't chipped, ANY access card with a key should work
        local prvkey = yatm_security.get_access_card_stack_prvkey(access_card)
        if yatm_core.is_blank(prvkey) then
          new_node.name = "yatm_mesecon_card_readers:mesecon_card_reader_error"
        else
          new_node.name = "yatm_mesecon_card_readers:mesecon_card_reader_on"
          mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(new_node))
        end
      end
      minetest.swap_node(pos, new_node)
    end,
  },
  on = {
    groups = {
      cracky = 1,
      mesecon_needs_receiver = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_common.back.on.png",
      "yatm_card_reader_reader.front.on.png",
    },

    mesecon = {
      receptor = {
        state = mesecon.state.on,
        rules = mesecon.rules.buttonlike_get,
      }
    },

    on_access_card_removed = function (pos, node, access_card)
      local new_node = { name = "yatm_mesecon_card_readers:mesecon_card_reader_off",
                         param1 = node.param1, param2 = node.param2 }
      minetest.swap_node(pos, new_node)
      mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
    end,
  },
  error = {
    groups = {
      cracky = 1,
      mesecon_needs_receiver = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_reader.side.png",
      "yatm_card_reader_common.back.error.png",
      "yatm_card_reader_reader.front.error.png",
    },

    mesecon = {
      receptor = {
        state = mesecon.state.off,
        rules = mesecon.rules.buttonlike_get,
      }
    },

    on_access_card_removed = function (pos, node, access_card)
      local new_node = { name = "yatm_mesecon_card_readers:mesecon_card_reader_off",
                         param1 = node.param1, param2 = node.param2 }
      minetest.swap_node(pos, new_node)
      mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
    end,
  }
})
