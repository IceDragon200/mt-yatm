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

yatm.register_stateful_node("yatm_mesecon_locks:mesecon_card_reader", {
  description = "Card Reader (Mesecons)",

  drop = "yatm_mesecon_locks:mesecon_card_reader_off",

  groups = {
    cracky = 1,
    mesecon_needs_receiver = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = default.node_sound_metal_defaults(),

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = reader_node_box,

  on_construct = card_reader_on_construct,

  on_rotate = mesecon.buttonlike_onrotate,
  on_blast = mesecon.on_blastnode,

  mesecon = {
    receptor = {
      state = mesecon.state.on,
      rules = mesecon.rules.buttonlike_get,
    }
  },

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

    on_access_card_inserted = function (pos, node, access_card)
      node.name = "yatm_mesecon_locks:mesecon_card_reader_on"
      minetest.swap_node(pos, node)
      mesecon.receptor_on(pos, mesecon.rules.buttonlike_get(node))
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

    on_access_card_removed = function (pos, node, access_card)
      node.name = "yatm_mesecon_locks:mesecon_card_reader_off"
      minetest.swap_node(pos, node)
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

    on_access_card_removed = function (pos, node, access_card)
      node.name = "yatm_mesecon_locks:mesecon_card_reader_off"
      minetest.swap_node(pos, node)
      mesecon.receptor_off(pos, mesecon.rules.buttonlike_get(node))
    end,
  }
})

if yatm_data_network then
  local data_network = assert(yatm.data_network)

  local data_interface = {}

  function data_interface.receive_pdu(pos, node, port, value)
    --
  end

  local function card_reader_refresh_infotext(pos, node)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end

  local function data_card_reader_on_construct(pos)
    card_reader_on_construct(pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end

  local function data_card_reader_after_destruct(pos, node)
    data_network:remove_node(pos, node)
  end

  yatm.register_stateful_node("yatm_mesecon_locks:data_card_reader", {
    description = "Card Reader (DATA)",

    drop = "yatm_mesecon_locks:data_card_reader_off",

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
    node_box = reader_node_box,

    data_network_device = {
      type = "device",
    },
    data_interface = data_interface,

    refresh_infotext = card_reader_refresh_infotext,

    on_construct = data_card_reader_on_construct,
    after_destruct = data_card_reader_after_destruct,

    on_rightclick = reader_on_rightclick,

    on_dig = reader_on_dig,
  }, {
    off = {
      tiles = {
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_data.back.off.png",
        "yatm_card_reader_reader.data.front.off.png",
      },

      on_access_card_inserted = function (pos, node, access_card)
        node.name = "yatm_mesecon_locks:data_card_reader_on"
        minetest.swap_node(pos, node)
      end,
    },

    on = {
      groups = {
        cracky = 1,
        yatm_data_device = 1,
        not_in_creative_inventory = 1,
      },

      tiles = {
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_data.back.on.png",
        "yatm_card_reader_reader.data.front.on.png",
      },

      on_access_card_removed = function (pos, node, access_card)
        node.name = "yatm_mesecon_locks:data_card_reader_off"
        minetest.swap_node(pos, node)
      end,
    },

    error = {
      groups = {
        cracky = 1,
        yatm_data_device = 1,
        not_in_creative_inventory = 1,
      },

      tiles = {
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_reader.side.png",
        "yatm_card_reader_data.back.error.png",
        "yatm_card_reader_reader.data.front.error.png",
      },

      on_access_card_removed = function (pos, node, access_card)
        node.name = "yatm_mesecon_locks:data_card_reader_off"
        minetest.swap_node(pos, node)
      end,
    }
  })
end
