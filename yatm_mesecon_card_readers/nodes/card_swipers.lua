local swiper_node_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new(0, 0, 15, 16, 16, 1):fast_node_box(),
    yatm_core.Cuboid:new( 1, 1,12, 3, 14, 3):fast_node_box(),
    yatm_core.Cuboid:new( 5, 1,12, 3, 14, 3):fast_node_box(),
  }
}

local function card_swiper_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()

  yatm_security.copy_chipped_object(old_meta, new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
end

local function card_swiper_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_security.copy_chipped_object(assert(old_meta), new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
  new_meta:set_string("infotext", new_meta:get_string("description"))
end

yatm.register_stateful_node("yatm_mesecon_card_readers:mesecon_card_swiper", {
  basename = "yatm_mesecon_card_readers:mesecon_card_swiper",

  description = "Card Swiper (Mesecons)",

  drop = "yatm_mesecon_card_readers:mesecon_card_swiper_off",

  groups = {
    cracky = 1,
    chippable_object = 1,
    mesecon_needs_receiver = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = default.node_sound_metal_defaults(),

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = swiper_node_box,

  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  preserve_metadata = card_swiper_preserve_metadata,
  after_place_node = card_swiper_after_place_node,
}, {
  off = {
    tiles = {
      "yatm_card_reader_swiper.top.png",
      "yatm_card_reader_swiper.bottom.png",
      "yatm_card_reader_swiper.side.png^[transformFX",
      "yatm_card_reader_swiper.side.png",
      "yatm_card_reader_common.back.off.png",
      "yatm_card_reader_swiper.front.off.png",
    },

    mesecon = {
      receptor = {
        state = mesecon.state.off,
        rules = mesecon.rules.buttonlike_get,
      }
    },

    on_rightclick = function (pos, node, _clicker, itemstack)
      local item = itemstack:get_definition()

      if yatm_core.groups.has_group(item, 'access_card') then
        node.name = "yatm_mesecon_card_readers:mesecon_card_swiper_on"
        minetest.swap_node(pos, node)
        minetest.get_node_timer(pos):start(1.0)
        mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(node))
      end
    end,
  },
  on = {
    groups = {
      cracky = 1,
      mesecon_needs_receiver = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_card_reader_swiper.top.png",
      "yatm_card_reader_swiper.bottom.png",
      "yatm_card_reader_swiper.side.png^[transformFX",
      "yatm_card_reader_swiper.side.png",
      "yatm_card_reader_common.back.on.png",
      "yatm_card_reader_swiper.front.on.png",
    },

    mesecon = {
      receptor = {
        state = mesecon.state.on,
        rules = mesecon.rules.buttonlike_get,
      }
    },

    on_timer = function (pos, elapsed)
      local node = minetest.get_node(pos)
      node.name = "yatm_mesecon_card_readers:mesecon_card_swiper_off"
      minetest.swap_node(pos, node)
      mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
      return false
    end,
  },
})