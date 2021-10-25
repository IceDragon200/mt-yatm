local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local is_blank = assert(foundation.com.is_blank)
local string_hex_escape = assert(foundation.com.string_hex_escape)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local string_bin_encode = assert(foundation.com.string_bin_encode)
local string_dec_encode = assert(foundation.com.string_dec_encode)
local string_hex_encode = assert(foundation.com.string_hex_encode)
local string_hex_decode = assert(foundation.com.string_hex_decode)
local string_pad_trailing = assert(foundation.com.string_pad_trailing)
local is_table_empty = assert(foundation.com.is_table_empty)
local data_network = assert(yatm.data_network)
local ByteDecoder = assert(yatm.ByteDecoder)
local fspec = assert(foundation.com.formspec.api)

-- Decoders use vectorized outputs
local VECTOR_CONFIG = {
  output_vector = 16
}

-- Input formats determine how individual values are read from a pdu
-- by default, they are treated as char (or u8)
local INPUT_FORMATS = {
  [1] = "char",
  [2] = "u8",
  [3] = "s8",
  [4] = "u16",
  [5] = "s16",
  [6] = "u24",
  [7] = "s24",
  [8] = "u32",
  [9] = "s32",
  [10] = "u64",
  [11] = "s64",
}

local INPUT_FORMATS_TO_INDEX = {}

for dec, str in pairs(INPUT_FORMATS) do
  INPUT_FORMATS_TO_INDEX[str] = dec
end

local DECODE_FORMATS = {
  [1] = "split",
  [2] = "binary",
  [3] = "decimal",
  [4] = "hex",
}

local DECODE_FORMATS_TO_INDEX = {}

for dec, str in pairs(DECODE_FORMATS) do
  DECODE_FORMATS_TO_INDEX[str] = dec
end

local function emit_last_value(pos, node)
  local meta = minetest.get_meta(pos)
  local value = meta:get_string("last_value")
  local decode_format = meta:get_string("decode_format")
  --print("receive_pdu", minetest.pos_to_string(pos), node.name, dir, port, dump(value), dump(decode_format))
  if not is_blank(decode_format) then
    -- handle hex escape codes i.e. '\x00'
    local str = string_hex_unescape(value)
    -- Decoders can only handle a maximum of 16 characters (which is enough for a 128 bit value)
    str = string.sub(str, 1, 16)

    local result

    if decode_format == "binary" then
      -- decimal splits a byte into 8 ascii components
      result = string_bin_encode(str)
    elseif decode_format == "decimal" then
      local input_format = meta:get_string("input_format")
      -- decimal splits a value into 3 ascii components
      -- decimal is the only problem child that needs to actually decode the value
      -- into it's integral parts
      if input_format == "" or input_format == "char" then
        result = string_dec_encode(str)
      else
        local value
        result = ""

        local rem = str
        while #rem > 0 do
          local len = #rem
          if input_format == "u8" then
            value = ByteDecoder:d_u8(rem)
            rem = string.sub(rem, 2)
          elseif input_format == "s8" then
            value = ByteDecoder:d_i8(rem)
            rem = string.sub(rem, 2)
          elseif input_format == "u16" then
            value = ByteDecoder:d_u16(rem)
            rem = string.sub(rem, 3)
          elseif input_format == "s16" then
            value = ByteDecoder:d_i16(rem)
            rem = string.sub(rem, 3)
          elseif input_format == "u24" then
            value = ByteDecoder:d_u24(rem)
            rem = string.sub(rem, 4)
          elseif input_format == "s24" then
            value = ByteDecoder:d_i24(rem)
            rem = string.sub(rem, 4)
          elseif input_format == "u32" then
            value = ByteDecoder:d_u32(rem)
            rem = string.sub(rem, 5)
          elseif input_format == "s32" then
            value = ByteDecoder:d_i32(rem)
            rem = string.sub(rem, 5)
          elseif input_format == "u64" then
            value = ByteDecoder:d_u64(rem)
            rem = string.sub(rem, 9)
          elseif input_format == "s64" then
            value = ByteDecoder:d_i64(rem)
            rem = string.sub(rem, 9)
          end
          result = result .. tostring(value)
        end
      end
    elseif decode_format == "hex" then
      -- splits a byte into 2 ascii components
      result = string_hex_encode(str)
    elseif decode_format == "split" then
      -- just split the string 'as is' across multiple output ports
      result = str
    end

    result = string_pad_trailing(result, 16, " ")

    meta:set_string("last_vector", string_hex_escape(result))
    yatm_data_logic.emit_output_data_vector(pos, result, VECTOR_CONFIG)
    yatm.queue_refresh_infotext(pos, node)
  end
end

minetest.register_node("yatm_data_logic:data_decoder", {
  description = "DATA Decoder\nUsed to transform raw bytes into other formats",

  codex_entry_id = "yatm_data_logic:data_decoder",

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

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_data_decoder_top.png",
    "yatm_data_decoder_bottom.png",
    "yatm_data_decoder_side.png",
    "yatm_data_decoder_side.png",
    "yatm_data_decoder_side.png",
    "yatm_data_decoder_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("decode_format", "split")

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
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
      meta:set_string("last_value", value)
      emit_last_value(pos, node)
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
        {
          tab_id = "data",
          title = "Data",
          header = "Data Configuration",
          render = {
            {
              component = "row",
              items = {
                {
                  component = "dropdown",
                  label = "Decode Format",
                  name = "decode_format",
                  type = "string",
                  meta = true,
                  items = DECODE_FORMATS,
                  index = DECODE_FORMATS_TO_INDEX,
                },
                {
                  component = "dropdown",
                  label = "Input Format",
                  name = "input_format",
                  type = "string",
                  meta = true,
                  items = INPUT_FORMATS,
                  index = INPUT_FORMATS_TO_INDEX,
                }
              }
            }
          }
        }
      }
    },

    receive_programmer_fields = {
      tabbed = true, -- notify the solver that tabs are in use
      tabs = {
        {
          components = {
            {component = "io_ports", mode = "o"}
          }
        },
        {
          components = {
            {
              component = "dropdown",
              name = "decode_format",
              type = "string",
              meta = true,
              index = DECODE_FORMATS_TO_INDEX,
            },
            {
              component = "dropdown",
              name = "input_format",
              type = "string",
              meta = true,
              index = INPUT_FORMATS_TO_INDEX,
            }
          }
        }
      }
    }
  },

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      "Last Input: " .. meta:get_string("last_value") .. "\n" ..
      "Last Vector: " .. meta:get_string("last_vector") .. "\n" ..
      "Input/Decode Format: " .. meta:get_string("input_format") .. "/" .. meta:get_string("decode_format") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
