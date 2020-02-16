--
-- Arithmetic Data Hubs
--
-- Each type has 2 modes:
--   Normal mode - input streams are treated as single numbers and will be affected by overflows
--   Vector mode - input streams are vectors, each byte in the stream is a single number and overflow is treated as a loop around
local data_network = assert(yatm.data_network)

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    local meta = minetest.get_meta(pos)

    local sub_network_ids = data_network:get_sub_network_ids(pos)
    local input_port = meta:get_int("input_" .. dir)
    if input_port > 0 then
      meta:set_string("input_value_" .. dir, value)

      local result = {}
      for _, dir in ipairs(yatm_core.DIR6) do
        if sub_network_ids[dir] then
          local port = meta:get_int("input_" .. dir)
          if port > 0 then
            local value = meta:get_string("input_value_" .. dir)

            result[dir] = yatm_core.string_hex_unescape(value)
          end
        end
      end

      local ops = meta:get_string("operands")
      local operands = {}
      for i = 1,#ops do
        operands[i] = string.sub(ops, i, i)
      end

      local new_value = self:operate(pos, node, result, operands)

      meta:set_string("last_value", new_value)

      yatm.queue_refresh_infotext(pos, node)
    end
  end,

  get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
    --
    local meta = minetest.get_meta(pos)

    assigns.tab = assigns.tab or 1

    local formspec =
      "size[8,9]" ..
      yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
      "tabheader[0,0;tab;Ports,Data;" .. assigns.tab .. "]"

    if assigns.tab == 1 then
      formspec =
        formspec ..
        "label[0,0;Port Configuration]"

      local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "io")

      formspec =
        formspec ..
        io_formspec

    elseif assigns.tab == 2 then
      formspec =
        formspec ..
        "label[0,0;Data Configuration]" ..
        "label[0,1;Operands]" ..
        "field[0.25,2;8,1;operands;Operands;" .. minetest.formspec_escape(meta:get_string("operands")) .. "]"
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

    local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "io")

    if not yatm_core.is_table_empty(inputs_changed) then
      yatm_data_logic.unmark_all_receive(assigns.pos)
      yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
    end

    if fields["operands"] then
      local operands = fields["operands"]
      local result = {}

      for i = 1,#operands do
        local char = string.sub(operands, i, i)

        if char == "N" or char == "n" then
          table.insert(result, "N")
        elseif char == "E" or char == "e" then
          table.insert(result, "E")
        elseif char == "S" or char == "s" then
          table.insert(result, "S")
        elseif char == "W" or char == "w" then
          table.insert(result, "W")
        elseif char == "U" or char == "u" then
          table.insert(result, "U")
        elseif char == "D" or char == "d" then
          table.insert(result, "D")
        end
      end

      result = table.concat(result)
      meta:set_string("operands", result)
      if result ~= operands then
        needs_refresh = true
      end
    end

    if needs_refresh then
      local formspec = self:get_programmer_formspec(assigns.pos, player, nil, assigns)
      return true, formspec
    else
      return true
    end
  end,
}

local function perform_borrow(accumulator, i)
  --accumulator[i] = accumulator[i] + 1
  local j = 1
  while accumulator[i + j] <= 0 and j <= 16 do
    j = j + 1
    if not accumulator[i + j] then
      accumulator[i + j] = 254
      break
    end
  end
  while j > 1 do
    j = j - 1
    accumulator[i + j] = accumulator[i + j] + 254
  end
  j = j - 1
  accumulator[i + j] = accumulator[i + j] + 255
end

yatm.register_stateful_node("yatm_data_logic:data_arith", {
  base_description = "Data Arithmetic",

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

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)

    meta:set_string("operands", "NESWUD")
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,

  data_network_device = {
    type = "device",
  },
  data_interface = data_interface,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      "Last Output: " .. meta:get_string("last_value") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  --
  -- Normal Mode
  --
  identity = {
    description = "Data Arithmetic [Identity]\nReturns data unchanged, it may replace any missing entries with other data from inputs",

    codex_entry_id = "yatm_data_logic:data_arith_identity",

    tiles = {
      "yatm_data_arith_top.identity.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local identity = {}

        for dir, value in pairs(values) do
          if #value > 0 then
            local result = yatm_core.string_hex_escape(value)
            yatm_data_logic.emit_output_data_value(pos, result)
            return result
          end
        end
      end,
    }),
  },

  add = {
    description = "Data Arithmetic [Addition]\nAdds all input data",

    codex_entry_id = "yatm_data_logic:data_arith_add",

    tiles = {
      "yatm_data_arith_top.add.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        local carry = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            accumulator[i] = accumulator[i] + byte + carry[i]
            carry[i] = 0
            if accumulator[i] > 255 then
              carry[i + 1] = math.floor(accumulator[i] / 256)
            end
            accumulator[i] = accumulator[i] % 256
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  subtract = {
    description = "Data Arithmetic [Subtraction]\nSubtracts input data",

    codex_entry_id = "yatm_data_logic:data_arith_subtract",

    tiles = {
      "yatm_data_arith_top.subtract.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, origin_values, operands)
        local values = yatm_core.table_copy(origin_values)
        local accumulator = {}

        for _, dir_code in ipairs(operands) do
          local value = values[yatm_core.STRING1_TO_DIR[dir_code]]
          for i = 1,16 do
            local byte = string.byte(value, i) or 0

            if accumulator[i] then
              accumulator[i] = accumulator[i] - byte
              if accumulator[i] < 0 then
                perform_borrow(accumulator, i)
              end
            else
              accumulator[i] = byte
            end
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  multiply = {
    description = "Data Arithmetic [Multiplication]\nMultiplies input data",

    codex_entry_id = "yatm_data_logic:data_arith_multiply",

    tiles = {
      "yatm_data_arith_top.multiply.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        local carry = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            accumulator[i] = accumulator[i] * byte + carry[i]
            carry[i] = 0
            if accumulator[i] > 255 then
              carry[i + 1] = math.floor(accumulator[i] / 256)
            end
            accumulator[i] = accumulator[i] % 256
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  divide = {
    description = "Data Arithmetic [Division]\nDivide Arithmetic",

    codex_entry_id = "yatm_data_logic:data_arith_divide",

    tiles = {
      "yatm_data_arith_top.divide.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {}

        for _, dir_code in ipairs(operands) do
          for i = 1,16 do
            local value = values[yatm_core.STRING1_TO_DIR[dir_code]]
            local byte = string.byte(value, i) or 0

            if accumulator[i] then
              if byte == 0 then
                accumulator[i] = 255
              else
                if accumulator < byte then
                  perform_borrow(accumulator, i)
                end
                accumulator[i] = accumulator[i] / byte
                carry[i] = 0
                if accumulator[i] > 255 then
                  carry[i + 1] = math.floor(accumulator[i] / 256)
                end
                accumulator[i] = accumulator[i] % 256
              end
            else
              accumulator[i] = byte
            end
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  max = {
    description = "Data Arithmetic [Max]",

    codex_entry_id = "yatm_data_logic:data_arith_max",

    tiles = {
      "yatm_data_arith_top.max.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator

        for dir, value in pairs(values) do
          if accumulator then
            if accumulator < value then
              accumulator = value
            end
          else
            accumulator = value
          end
        end

        value = yatm_core.string_hex_escape(accumulator)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  min = {
    description = "Data Arithmetic [Min]",

    codex_entry_id = "yatm_data_logic:data_arith_min",

    tiles = {
      "yatm_data_arith_top.min.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator

        for dir, value in pairs(values) do
          if accumulator then
            if accumulator > value then
              accumulator = value
            end
          else
            accumulator = value
          end
        end

        value = yatm_core.string_hex_escape(accumulator)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },
  --
  -- Vector Mode
  --
  identity_vector = {
    description = "Data Arithmetic [Identity Vector]\nReturns data unchanged",

    codex_entry_id = "yatm_data_logic:data_arith_identity_vector",

    tiles = {
      "yatm_data_arith_top.identity.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local identity = {}

        for dir, value in pairs(values) do
          for i = 1,16 do
            identity[i] = identity[i] or string.sub(value, i, i)
          end
        end

        for i = 1,16 do
          identity[i] = identity[i] or " "
        end

        local value = table.concat(identity)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  add_vector = {
    description = "Data Arithmetic [Addition Vector]\nAdds all input data",

    codex_entry_id = "yatm_data_logic:data_arith_add_vector",

    tiles = {
      "yatm_data_arith_top.add.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            accumulator[i] = (accumulator[i] + byte) % 256
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  subtract_vector = {
    description = "Data Arithmetic [Subtraction Vector]\nSubtracts input data",

    codex_entry_id = "yatm_data_logic:data_arith_subtract_vector",

    tiles = {
      "yatm_data_arith_top.subtract.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            accumulator[i] = (accumulator[i] - byte) % 256
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  multiply_vector = {
    description = "Data Arithmetic [Multiplication Vector]\nMultiply input data",

    codex_entry_id = "yatm_data_logic:data_arith_multiply_vector",

    tiles = {
      "yatm_data_arith_top.multiply.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            accumulator[i] = (accumulator[i] * byte) % 256
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  divide_vector = {
    description = "Data Arithmetic [Division Vector]\nDivide input data",

    codex_entry_id = "yatm_data_logic:data_arith_divide_vector",

    tiles = {
      "yatm_data_arith_top.divide.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            if byte == 0 then
              accumulator[i] = 255 -- simulate some infinite condition without crashing
            else
              accumulator[i] = (accumulator[i] / byte) % 256
            end
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  max_vector = {
    description = "Data Arithmetic [Max Vector]\nPick largest input data",

    codex_entry_id = "yatm_data_logic:data_arith_max_vector",

    tiles = {
      "yatm_data_arith_top.max.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            if accumulator[i] then
              if byte > accumulator[i] then
                accumulator[i] = byte
              end
            else
              accumulator[i] = byte
            end
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },

  min_vector = {
    description = "Data Arithmetic [Min Vector]\nPick smallest input data",

    codex_entry_id = "yatm_data_logic:data_arith_min_vector",

    tiles = {
      "yatm_data_arith_top.min.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, values, operands)
        local accumulator = {}

        for i = 1,16 do
          for dir, value in pairs(values) do
            local byte = string.byte(value, i) or 0

            if accumulator[i] then
              if byte < accumulator[i] then
                accumulator[i] = byte
              end
            else
              accumulator[i] = byte
            end
          end
        end

        local result = {}
        for i = 1,16 do
          result[i] = string.char(accumulator[i])
        end
        local value = table.concat(result)
        value = yatm_core.string_hex_escape(value)
        yatm_data_logic.emit_output_data_value(pos, value)

        return value
      end,
    }),
  },
})
