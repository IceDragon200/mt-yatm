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

    on_rightclick = function (pos, node, _clicker, itemstack)
      local item = itemstack:get_definition()

      if yatm_core.groups.has_group(item, 'access_card') then
        if yatm_security.is_chipped_node(pos) then
          if yatm_security.is_stack_an_access_card_for_chipped_node(itemstack, pos) then
            node.name = "yatm_data_card_readers:data_card_swiper_on"
            local prvkey = yatm_security.get_access_card_stack_prvkey(itemstack)
            yatm_data_logic.emit_output_data_value(pos, prvkey)
          else
            node.name = "yatm_data_card_readers:data_card_swiper_error"
          end
        else
          -- if the swiper isn't chipped, ANY access card should work
          local prvkey = yatm_security.get_access_card_stack_prvkey(itemstack)
          if yatm_core.is_blank(prvkey) then
            -- unless it doesn't have a prvkey in which case this is an error
            node.name = "yatm_data_card_readers:data_card_swiper_error"
          else
            node.name = "yatm_data_card_readers:data_card_swiper_on"
            yatm_data_logic.emit_output_data_value(pos, prvkey)
          end
        end
        minetest.swap_node(pos, node)
        minetest.get_node_timer(pos):start(1.0)
      end
    end,
  },

  error = {
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
      "yatm_card_reader_data.back.error.png",
      "yatm_card_reader_swiper.data.front.error.png",
    },

    on_timer = function (pos, elapsed)
      local node = minetest.get_node(pos)
      node.name = "yatm_data_card_readers:data_card_swiper_off"
      minetest.swap_node(pos, node)
      return false
    end,
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

    on_timer = function (pos, elapsed)
      local node = minetest.get_node(pos)
      node.name = "yatm_data_card_readers:data_card_swiper_off"
      minetest.swap_node(pos, node)
      return false
    end,
  }
})
