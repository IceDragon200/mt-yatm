local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Groups = assert(foundation.com.Groups)
local FakeMetaRef = assert(foundation.com.FakeMetaRef)
local is_table_empty = assert(foundation.com.is_table_empty)
local is_blank = assert(foundation.com.is_blank)
local data_network = assert(yatm.data_network)

local reader_node_box = {
  type = "fixed",
  fixed = {
    ng( 0,  0, 13, 16, 16, 3),
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
      if Groups.has_group(item, 'access_card') then
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

local function card_reader_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    meta:get_string("description") .. "\n" ..
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

local function data_card_reader_preserve_metadata(pos, oldnode, old_meta_table, drops)
  local stack = drops[1]

  local old_meta = FakeMetaRef:new(old_meta_table)
  local new_meta = stack:get_meta()

  yatm_security.copy_chipped_object(old_meta, new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
end

local function data_card_reader_after_place_node(pos, _placer, itemstack, _pointed_thing)
  local new_meta = minetest.get_meta(pos)
  local old_meta = itemstack:get_meta()

  yatm_security.copy_chipped_object(assert(old_meta), new_meta)

  new_meta:set_string("description", old_meta:get_string("description"))
  new_meta:set_string("infotext", new_meta:get_string("description"))
end

yatm.register_stateful_node("yatm_data_card_readers:data_card_reader", {
  codex_entry_id = "yatm_data_card_readers:data_card_reader",

  basename = "yatm_data_card_readers:data_card_reader",

  description = "Card Reader (DATA)",

  drop = "yatm_data_card_readers:data_card_reader_off",

  groups = {
    cracky = 1,
    chippable_object = 1,
    yatm_data_device = 1,
    data_programmable = 1,
  },

  sunlight_propagates = false,
  is_ground_content = false,

  sounds = yatm.node_sounds:build("metal"),

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = reader_node_box,

  data_network_device = {
    type = "device",
  },

  data_interface = {
    on_load = function (self, pos, node)
      --
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
    end,

    get_programmer_formspec = {
      default_tab = "ports",
      tabs = {
        {
          tab_id = "ports",
          title = "Ports",
          header = "Port Configuration",
          render = {
            {
              component = "io_ports",
              mode = "io",
            }
          },
        },
      }
    },

    receive_programmer_fields = {
      tabbed = true, -- notify the solver that tabs are in use
      tabs = {
        {
          components = {
            {
              component = "io_ports",
              mode = "io",
            }
          }
        },
      }
    },
  },

  refresh_infotext = card_reader_refresh_infotext,

  on_construct = data_card_reader_on_construct,
  after_destruct = data_card_reader_after_destruct,

  on_rightclick = reader_on_rightclick,

  on_dig = reader_on_dig,

  preserve_metadata = data_card_reader_preserve_metadata,
  after_place_node = data_card_reader_after_place_node,

  use_texture_alpha = "opaque",
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
    use_texture_alpha = "opaque",

    on_access_card_inserted = function (pos, node, access_card)
      if yatm_security.is_chipped_node(pos) then
        if yatm_security.is_stack_an_access_card_for_chipped_node(access_card, pos) then
          node.name = "yatm_data_card_readers:data_card_reader_on"
          local prvkey = yatm_security.get_access_card_stack_prvkey(access_card)
          yatm_data_logic.emit_output_data_value(pos, prvkey)
        else
          node.name = "yatm_data_card_readers:data_card_reader_error"
        end
      else
        -- if the swiper isn't chipped, ANY access card should work
        local prvkey = yatm_security.get_access_card_stack_prvkey(access_card)
        if is_blank(prvkey) then
          node.name = "yatm_data_card_readers:data_card_reader_error"
        else
          node.name = "yatm_data_card_readers:data_card_reader_on"
          yatm_data_logic.emit_output_data_value(pos, prvkey)
        end
      end
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
    use_texture_alpha = "opaque",

    on_access_card_removed = function (pos, node, access_card)
      node.name = "yatm_data_card_readers:data_card_reader_off"
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
    use_texture_alpha = "opaque",

    on_access_card_removed = function (pos, node, access_card)
      node.name = "yatm_data_card_readers:data_card_reader_off"
      minetest.swap_node(pos, node)
    end,
  }
})
