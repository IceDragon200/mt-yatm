local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local string_hex_decode = assert(foundation.com.string_hex_decode)
local string_hex_clean = assert(foundation.com.string_hex_clean)
local string_pad_trailing = assert(foundation.com.string_pad_trailing)
local string_hex_encode = assert(foundation.com.string_hex_encode)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local string_hex_escape = assert(foundation.com.string_hex_escape)
local string_sub_join = assert(foundation.com.string_sub_join)
local binary_splice = assert(foundation.com.binary_splice)
local data_network = assert(yatm.data_network)
local ByteDecoder = yatm.ByteDecoder

if not ByteDecoder then
  minetest.log("warning", "Memory module requires yatm.ByteDecoder")
  return
end

local function get_memory_binary(meta)
  return string_hex_decode(meta:get_string("memory"))
end

local function set_memory_blob(meta, memory)
  memory = string_hex_clean(memory) -- remove any non-hex characters from the blob
  memory = string_hex_decode(memory) -- decode it as binary
  memory = string_pad_trailing(string.sub(memory, 1, 256), 256, "\x00") -- limit it to 256 characters
  memory = string_hex_encode(memory) -- re-encode the result
  meta:set_string("memory", memory) -- store it
end

minetest.register_node("yatm_data_logic:data_memory", {
  description = "Data Memory",

  codex_entry_id = "yatm_data_logic:data_memory",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      ng(0, 0, 0, 16, 4, 16),
      ng(3, 4, 3, 10, 1, 10),
    },
  },

  tiles = {
    "yatm_data_memory_top.png",
    "yatm_data_memory_bottom.png",
    "yatm_data_memory_side.png",
    "yatm_data_memory_side.png",
    "yatm_data_memory_side.png",
    "yatm_data_memory_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    set_memory_blob(meta, "")

    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      yatm_data_logic.bind_matrix_ports(pos, "port", "read", "active")
      yatm_data_logic.bind_matrix_ports(pos, "port", "write", "active")
      yatm_data_logic.bind_matrix_ports(pos, "port", "address", "active")
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
      local blob = string_hex_unescape(value)

      if yatm_data_logic.get_matrix_port(pos, "port", "address", dir) == port then
        local cell_id = ByteDecoder:d_u8(blob)
        meta:set_int("address_offset", cell_id) -- address offset is 0-offset, not 1
      end

      if yatm_data_logic.get_matrix_port(pos, "port", "write", dir) == port then
        local cell_value = ByteDecoder:d_u8(blob)
        local memory = get_memory_binary(meta)
        -- reminder that address offset is a 0-offset
        local address_offset = meta:get_int("address_offset")
        memory = binary_splice(memory, address_offset + 1, 1, cell_value)
        meta:set_string("memory", string_hex_encode(memory))
      end

      if yatm_data_logic.get_matrix_port(pos, "port", "read", dir) == port then
        local cell_id_offset = ByteDecoder:d_u8(blob)
        local memory = get_memory_binary(meta)
        -- yet another reminder that address offset is a 0-offset
        local address_offset = meta:get_int("address_offset")
        local cell_id = (address_offset + cell_id_offset) % 256 + 1
        local output_value = string_hex_escape(string.sub(memory, cell_id, cell_id))
        yatm_data_logic.emit_matrix_port_value(pos, "port", "data", output_value)
      end
    end,

    get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1

      local formspec =
        yatm_data_logic.layout_formspec() ..
        yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
        "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0,0;Port Configuration]" ..
          yatm_data_logic.get_port_matrix_formspec(pos, meta, {
            width = 12,
            sections = {
              {
                name = "port",
                label = nil,
                cols = 4,
                port_count = 4,
                port_names = {"data", "read", "write", "address"},
                port_labels = {"Data", "Read", "Write", "Address"},
              }
            }
          })
      elseif assigns.tab == 2 then
        local memory_blob = meta:get_string("memory")
        memory_blob = string_sub_join(memory_blob, 32, "\n")
        memory_blob = minetest.formspec_escape(memory_blob)

        local address_blob = minetest.formspec_escape(meta:get_int("address_offset"))

        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "field[0.3,1;8,1;address;Address;" .. address_blob .. "]" ..
          "textarea[0.3,2;8,8;memory;Memory;" .. memory_blob .. "]"
      end

      return formspec
    end,

    receive_programmer_fields = function (self, player, form_name, fields, assigns)
      local meta = minetest.get_meta(assigns.pos)

      local needs_refresh = false

      if fields["tab"] then
        local tab = tonumber(fields["tab"])
        if tab ~= assigns.tab then
          assigns.tab = tab
          needs_refresh = true
        end
      end

      if fields["address"] then
        local address = tonumber(fields["address"])
        meta:set_int("address_offset", address)
      end

      if fields["memory"] then
        local memory = fields["memory"]
        set_memory_blob(meta, memory)
      end

      local sections_changed =
        yatm_data_logic.handle_port_matrix_fields(assigns.pos, fields, meta, {
          sections = {
            {
              name = "port",
              port_count = 4,
              port_names = {"data", "read", "write", "address"},
            }
          }
        })

      if sections_changed.port then
        if sections_changed.port.data then
          -- this is an output port
        end

        yatm_data_logic.unmark_all_receive(assigns.pos)

        yatm_data_logic.bind_matrix_ports(assigns.pos, "port", "read", "active")
        yatm_data_logic.bind_matrix_ports(assigns.pos, "port", "write", "active")
        yatm_data_logic.bind_matrix_ports(assigns.pos, "port", "address", "active")
      end

      if needs_refresh then
        local formspec = self:get_programmer_formspec(assigns.pos, player, nil, assigns)
        return true, formspec
      else
        return true
      end
    end,
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
