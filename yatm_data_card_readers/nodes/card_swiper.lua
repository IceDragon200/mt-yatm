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

yatm.register_stateful_node("yatm_data_card_readers:data_card_swiper", {
  basename = "yatm_data_card_readers:data_card_swiper",

  description = "Card Swiper (DATA)",

  drop = "yatm_data_card_readers:data_card_swiper_off",

  groups = {
    cracky = 1,
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
