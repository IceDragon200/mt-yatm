local data_network = assert(yatm.data_network)

local ASCII_TABLE = {}
local SPACE = string.byte(" ")
for i = 0,255 do
  -- remap everything to whitespace
  ASCII_TABLE[i] = SPACE
end

for i = 33,95 do
  -- supported characters
  ASCII_TABLE[i] = i
end

for i = 97,122 do
  ASCII_TABLE[i] = i - 32
end

ASCII_TABLE[123] = 123
ASCII_TABLE[124] = 124
ASCII_TABLE[125] = 125

local states = {}

for ascii_code, new_ascii_code in pairs(ASCII_TABLE) do
  if not states[new_ascii_code] then
    local groups = {
      cracky = 1,
      data_programmable = 1,
      yatm_data_device = 1,
    }

    local top_tile
    if new_ascii_code ~= SPACE then
      top_tile = "yatm_data_char_display_top.png^" .. "yatm_yatm_blocky_font_" .. new_ascii_code .. ".png"
      groups.not_in_creative_inventory = 1
    else
      top_tile = "yatm_data_char_display_top.png"
    end

    states[new_ascii_code] = {
      description = "ASCII Display [" .. string.char(new_ascii_code) .. "]",

      groups = groups,

      ascii_char = string.char(new_ascii_code),

      tiles = {
        top_tile,
        "yatm_data_char_display_bottom.png",
        "yatm_data_char_display_side.png",
        "yatm_data_char_display_side.png",
        "yatm_data_char_display_side.png",
        "yatm_data_char_display_side.png",
      }
    }
  end
end

yatm.register_stateful_node("yatm_data_display:ascii_display", {
  codex_entry_id = "yatm_data_display:ascii_display",

  base_description = "ASCII Display",

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(),
    },
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_place_node = yatm_core.facedir_wallmount_after_place_node,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
    groups = {},
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)

      local str = yatm_core.string_hex_unescape(value)
      local byte = string.byte(str)
      if byte then
        local new_name = "yatm_data_display:ascii_display_" .. ASCII_TABLE[byte]

        if new_name ~= node.name then
          local new_node = {
            name = new_name,
            param1 = node.param1,
            param2 = node.param2,
          }
          minetest.swap_node(pos, new_node)
          data_network:upsert_member(pos, new_node)
          yatm.queue_refresh_infotext(pos, new_node)
        end
      end
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)

      local formspec =
        "size[8,9]" ..
        yatm.formspec_bg_for_player(user:get_player_name(), "display") ..
        "label[0,0;Port Configuration]" ..
        yatm_data_logic.get_io_port_formspec(pos, meta, "i")

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "i")

      if not yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
      end

      return true
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]

    local infotext =
      "ASCII Display: " .. nodedef.ascii_char .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, states)
