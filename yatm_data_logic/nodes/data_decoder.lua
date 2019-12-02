local data_network = assert(yatm.data_network)

-- Decoders use vectorized outputs
local VECTOR_CONFIG = {
  output_vector = 16
}

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
  if not yatm_core.is_blank(decode_format) then
    -- handle hex escape codes i.e. '\x00'
    local str = yatm_core.string_hex_unescape(value)
    -- Decoders can only handle a maximum of 16 characters
    str = string.sub(str, 1, 16)

    local result
    if decode_format == "binary" then
      -- decimal splits a byte into 8 ascii components
      result = yatm_core.string_bin_encode(str)
    elseif decode_format == "decimal" then
      -- decimal splits a byte into 3 ascii components
      result = yatm_core.string_dec_encode(str)
    elseif decode_format == "hex" then
      -- splits a byte into 2 ascii components
      result = yatm_core.string_hex_encode(str)
    elseif decode_format == "split" then
      -- just split the string 'as is' across multiple output ports
      result = str
    end

    result = yatm_core.string_pad_trailing(result, 16, " ")

    meta:set_string("last_vector", yatm_core.string_hex_escape(result))
    yatm_data_logic.emit_output_data_vector(pos, result, VECTOR_CONFIG)
    yatm.queue_refresh_infotext(pos, node)
  end
end

minetest.register_node("yatm_data_logic:data_decoder", {
  description = "Data Decoder\nUsed to transform raw bytes into other formats",

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
      yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(),
      yatm_core.Cuboid:new(3, 4, 3, 10, 1, 10):fast_node_box(),
    },
  },

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

    get_programmer_formspec = function (self, pos, clicker, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)
      assigns.tab = assigns.tab or 1
      local formspec =
        "size[8,9]" ..
        yatm.bg.module ..
        "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

      if assigns.tab == 1 then
        formspec =
          formspec ..
          "label[0,0;Port Configuration]" ..
          yatm_data_logic.get_io_port_formspec(pos, meta, "io", VECTOR_CONFIG)
      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "dropdown[0.25,1;8,1;decode_format" ..
            ";" .. table.concat(DECODE_FORMATS, ",") ..
            ";" .. (DECODE_FORMATS_TO_INDEX[meta:get_string("decode_format")] or 1) ..
          "]"
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

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "io", VECTOR_CONFIG)

      if not yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
      end

      local decode_format = fields["decode_format"]
      if decode_format then
        --print("receive_fields", "decode_format", dump(decode_format))
        if DECODE_FORMATS_TO_INDEX[decode_format] then
          meta:set_string("decode_format", decode_format)
        else
          print("invalid decode format " .. dump(decode_format))
        end
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
      "Last Input: " .. meta:get_string("last_value") .. "\n" ..
      "Last Vector: " .. meta:get_string("last_vector") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
