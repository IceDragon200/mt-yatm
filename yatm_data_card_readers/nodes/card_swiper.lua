local data_network = assert(yatm.data_network)

local swiper_node_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new(0, 0, 15, 16, 16, 1):fast_node_box(),
    yatm_core.Cuboid:new( 1, 1,12, 3, 14, 3):fast_node_box(),
    yatm_core.Cuboid:new( 5, 1,12, 3, 14, 3):fast_node_box(),
  }
}

local function card_swiper_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function card_swiper_on_construct(pos)
  local node = minetest.get_node(pos)
  data_network:add_node(pos, node)
end

local function card_swiper_after_destruct(pos, node)
  data_network:remove_node(pos, node)
end

local function data_card_swiper_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = yatm_core.FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()

  yatm_security.copy_chipped_object(old_meta, new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
end

local function data_card_swiper_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_security.copy_chipped_object(assert(old_meta), new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
  new_meta:set_string("infotext", new_meta:get_string("description"))
end

yatm.register_stateful_node("yatm_data_card_readers:data_card_swiper", {
  basename = "yatm_data_card_readers:data_card_swiper",

  description = "Card Swiper (DATA)",

  drop = "yatm_data_card_readers:data_card_swiper_off",

  groups = {
    cracky = 1,
    chippable_object = 1,
    yatm_data_device = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = default.node_sound_metal_defaults(),

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = swiper_node_box,

  on_construct = card_swiper_on_construct,
  after_destruct = card_swiper_after_destruct,

  preserve_metadata = data_card_swiper_preserve_metadata,
  after_place_node = data_card_swiper_after_place_node,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (pos, node)
      --
    end,

    receive_pdu = function (pos, node, dir, port, value)
      --
    end,
  },

  refresh_infotext = card_swiper_refresh_infotext,
}, {
  off = {
    tiles = {
      "yatm_card_reader_swiper.top.png",
      "yatm_card_reader_swiper.bottom.png",
      "yatm_card_reader_swiper.side.png^[transformFX",
      "yatm_card_reader_swiper.side.png",
      "yatm_card_reader_data.back.off.png",
      "yatm_card_reader_swiper.data.front.off.png",
    },
  },

  on = {
    groups = {
      cracky = 1,
      yatm_data_device = 1,
      not_in_creative_inventory = 1,
    },

    tiles = {
      "yatm_card_reader_swiper.top.png",
      "yatm_card_reader_swiper.bottom.png",
      "yatm_card_reader_swiper.side.png^[transformFX",
      "yatm_card_reader_swiper.side.png",
      "yatm_card_reader_data.back.on.png",
      "yatm_card_reader_swiper.data.front.on.png",
    },
  }
})
