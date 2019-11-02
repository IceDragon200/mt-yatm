local swiper_node_box = {
  type = "fixed",
  fixed = {
    yatm_core.Cuboid:new(0, 0, 15, 16, 16, 1):fast_node_box(),
    yatm_core.Cuboid:new( 1, 1,12, 3, 14, 3):fast_node_box(),
    yatm_core.Cuboid:new( 5, 1,12, 3, 14, 3):fast_node_box(),
  }
}

minetest.register_node("yatm_mesecon_locks:mesecon_card_swiper_off", {
  description = "Card Swiper (Mesecons)",

  drop = "yatm_mesecon_locks:mesecon_card_swiper_off",

  groups = {
    cracky = 1,
    mesecon_needs_receiver = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = default.node_sound_metal_defaults(),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_card_reader_swiper.top.png",
    "yatm_card_reader_swiper.bottom.png",
    "yatm_card_reader_swiper.side.png^[transformFX",
    "yatm_card_reader_swiper.side.png",
    "yatm_card_reader_common.back.off.png",
    "yatm_card_reader_swiper.front.off.png",
  },
  drawtype = "nodebox",
  node_box = swiper_node_box,

  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  mesecon = {
    receptor = {
      state = mesecon.state.off,
      rules = mesecon.rules.buttonlike_get,
    }
  },

  on_rightclick = function (pos, node, _clicker, itemstack)
    local item = itemstack:get_definition()

    if yatm_core.groups.has_group(item, 'access_card') then
      node.name = "yatm_mesecon_locks:mesecon_card_swiper_on"
      minetest.swap_node(pos, node)
      minetest.get_node_timer(pos):start(1.0)
      mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(node))
    end
  end,
})

minetest.register_node("yatm_mesecon_locks:mesecon_card_swiper_on", {
  description = "Card Swiper (Mesecons)",

  drop = "yatm_mesecon_locks:mesecon_card_swiper_off",

  groups = {
    cracky = 1,
    mesecon_needs_receiver = 1,
    not_in_creative_inventory = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = default.node_sound_metal_defaults(),

  paramtype = "light",
  paramtype2 = "facedir",

  tiles = {
    "yatm_card_reader_swiper.top.png",
    "yatm_card_reader_swiper.bottom.png",
    "yatm_card_reader_swiper.side.png^[transformFX",
    "yatm_card_reader_swiper.side.png",
    "yatm_card_reader_common.back.on.png",
    "yatm_card_reader_swiper.front.on.png",
  },
  drawtype = "nodebox",
  node_box = swiper_node_box,

  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  mesecon = {
    receptor = {
      state = mesecon.state.on,
      rules = mesecon.rules.buttonlike_get,
    }
  },

  on_timer = function (pos, elapsed)
    local node = minetest.get_node(pos)
    node.name = "yatm_mesecon_locks:mesecon_card_swiper_off"
    minetest.swap_node(pos, node)
    mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
    return false
  end,
})

if yatm_data_network then
  local data_network = assert(yatm.data_network)

  local data_interface = {}

  function data_interface.receive_pdu(pos, node, port, value)
    --
  end

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

  minetest.register_node("yatm_mesecon_locks:data_card_swiper_off", {
    description = "Card Swiper (DATA)",

    drop = "yatm_mesecon_locks:data_card_swiper_off",

    groups = {
      cracky = 1,
      yatm_data_device = 1,
    },

    sunlight_propagates = false,
    is_ground_content = false,

    sounds = default.node_sound_metal_defaults(),

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {
      "yatm_card_reader_swiper.top.png",
      "yatm_card_reader_swiper.bottom.png",
      "yatm_card_reader_swiper.side.png^[transformFX",
      "yatm_card_reader_swiper.side.png",
      "yatm_card_reader_data.back.off.png",
      "yatm_card_reader_swiper.data.front.off.png",
    },
    drawtype = "nodebox",
    node_box = swiper_node_box,

    data_network_device = {
      type = "device",
    },
    data_interface = data_interface,

    refresh_infotext = card_swiper_refresh_infotext,
  })

  minetest.register_node("yatm_mesecon_locks:data_card_swiper_on", {
    description = "Card Swiper (DATA)",

    drop = "yatm_mesecon_locks:data_card_swiper_off",

    groups = {
      cracky = 1,
      yatm_data_device = 1,
      not_in_creative_inventory = 1,
    },

    sunlight_propagates = false,
    is_ground_content = false,

    sounds = default.node_sound_metal_defaults(),

    paramtype = "light",
    paramtype2 = "facedir",

    tiles = {
      "yatm_card_reader_swiper.top.png",
      "yatm_card_reader_swiper.bottom.png",
      "yatm_card_reader_swiper.side.png^[transformFX",
      "yatm_card_reader_swiper.side.png",
      "yatm_card_reader_data.back.on.png",
      "yatm_card_reader_swiper.data.front.on.png",
    },
    drawtype = "nodebox",
    node_box = swiper_node_box,

    data_network_device = {
      type = "device",
    },
    data_interface = data_interface,

    refresh_infotext = card_swiper_refresh_infotext,
  })
end
