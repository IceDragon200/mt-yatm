local Directions = assert(foundation.com.Directions)
local list_map = assert(foundation.com.list_map)
local string_split = assert(foundation.com.string_split)
local data_network = assert(yatm.data_network)
local bit = assert(foundation.com.bit)

yatm_data_logic.INTERVAL_LIST = {
  {
    id = 1,
    value = "1",
    duration = 1.0,
  },
  {
    id = 2,
    value = "1/2",
    duration = 1/2,
  },
  {
    id = 3,
    value = "1/3",
    duration = 1/3,
  },
  {
    id = 4,
    value = "1/4",
    duration = 1/4,
  },
  {
    id = 5,
    value = "1/5",
    duration = 1/5,
  },
  {
    id = 6,
    value = "1/6",
    duration = 1/6,
  },
  {
    id = 7,
    value = "1/8",
    duration = 1/8,
  },
  {
    id = 8,
    value = "1/10",
    duration = 1/10,
  },
  {
    id = 9,
    value = "1/12",
    duration = 1/12,
  },
  {
    id = 10,
    value = "1/16",
    duration = 1/16,
  }
}

yatm_data_logic.INTERVALS = {}
for _, item in ipairs(yatm_data_logic.INTERVAL_LIST) do
  yatm_data_logic.INTERVALS[item.value] = item
end

yatm_data_logic.INTERVAL_STRING = table.concat(list_map(yatm_data_logic.INTERVAL_LIST, function (item)
  return item.value
end), ",")

local function toggle_bit(value, pos)
  return bit.bxor(value, bit.lshift(1, pos))
end

-- @spec yatm_data_logic.encode_varuint(value: Integer, length: Integer) :: String
function yatm_data_logic.encode_varuint(value, length)
  local now = value
  local result = {}
  local j = 0
  for i = 1,length do
    j = j + 1
    result[j] = string.char(now % 256)
    now = math.floor(now / 256)
  end
  return table.concat(result)
end

-- @spec yatm_data_logic.encode_u8(value: Integer) :: String
function yatm_data_logic.encode_u8(value)
  return yatm_data_logic.encode_varuint(value, 1)
end

-- @spec yatm_data_logic.encode_u16(value: Integer) :: String
function yatm_data_logic.encode_u16(value)
  return yatm_data_logic.encode_varuint(value, 2)
end

-- @spec yatm_data_logic.encode_u24(value: Integer) :: String
function yatm_data_logic.encode_u24(value)
  return yatm_data_logic.encode_varuint(value, 3)
end

-- @spec yatm_data_logic.encode_u32(value: Integer) :: String
function yatm_data_logic.encode_u32(value)
  return yatm_data_logic.encode_varuint(value, 4)
end

--
-- Unbind input on ALL directions for specified position
--
function yatm_data_logic.unmark_all_receive(pos)
  assert(pos, "expected a position")
  data_network:unmark_ready_to_receive(pos, 0, 0)
end

--
-- Bind specified port to ALL directions on the position
--
function yatm_data_logic.bind_input_port(pos, local_port, bind_type)
  for _, dir in ipairs(Directions.DIR6) do
    data_network:mark_ready_to_receive(pos, dir, local_port, bind_type or "active")
  end
end

--
-- Marks all input ports as active, that is to ALWAYS receive data
--
function yatm_data_logic.mark_all_inputs_for_active_receive(pos, options)
  assert(pos, "requires a position")
  options = options or {}
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids_by_color(pos)

  for _, dir in ipairs(Directions.DIR6) do
    if options.input_vector then
      for i = 1,options.input_vector do
        local local_port = meta:get_int("input_" .. dir .. "_" .. i)

        if local_port and local_port > 0 then
          data_network:mark_ready_to_receive(pos, dir, local_port, "active")
        end
      end
    else
      local local_port = meta:get_int("input_" .. dir)

      if local_port and local_port > 0 then
        data_network:mark_ready_to_receive(pos, dir, local_port, "active")
      end
    end
  end
end

--
-- Treats the specified value as a vector, that is each value in the string is outputted on a different port
--
-- @spec yatm_data_logic.emit_output_data_vector(pos: Vector, vector_value: String, options: Table) :: boolean
function yatm_data_logic.emit_output_data_vector(pos, vector_value, options)
  options = options or {}
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids(pos)

  local did_output = false

  if vector_value and #vector_value > 0 then
    for _, dir in ipairs(Directions.DIR6) do
      if options.output_vector then
        for i = 1,options.output_vector do
          local local_port = meta:get_int("output_" .. dir .. "_" .. i)

          if local_port and local_port > 0 then
            local char = string.sub(vector_value, i, i)
            data_network:send_value(pos, dir, local_port, char)
            did_output = true
          end
        end
      else
        local local_port = meta:get_int("output_" .. dir)

        if local_port and local_port > 0 then
          data_network:send_value(pos, dir, local_port, vector_value)
          did_output = true
        end
      end
    end
  end
  return did_output
end

function yatm_data_logic.get_matrix_port(pos, port_prefix, port_name, dir)
  local meta = minetest.get_meta(pos)
  local port_field_name = port_prefix .. "_" .. dir .. "_" .. port_name

  return meta:get_int(port_field_name)
end

function yatm_data_logic.bind_matrix_ports(pos, port_prefix, port_name, bind_type)
  assert(pos, "expected a position")
  assert(port_prefix, "expected a port_prefix")
  assert(port_name, "expected a port_name")
  bind_type = bind_type or "active"
  for _, dir in ipairs(Directions.DIR6) do
    local local_port = yatm_data_logic.get_matrix_port(pos, port_prefix, port_name, dir)
    if local_port > 0 then
      data_network:mark_ready_to_receive(pos, dir, local_port, bind_type)
    end
  end
end

function yatm_data_logic.emit_matrix_port_value(pos, port_prefix, port_name, value)
  local meta = minetest.get_meta(pos)
  local sub_network_ids = data_network:get_sub_network_ids(pos)

  for _, dir in ipairs(Directions.DIR6) do
    local port_field_name = port_prefix .. "_" .. dir .. "_" .. port_name
    local local_port = meta:get_int(port_field_name)
    --print("emit_port_value", port_field_name, "port_prefix=" .. port_prefix,
    --                                     "port_name=" .. port_name,
    --                                     "value=" .. dump(value),
    --                                     "local_port=" .. local_port)
    if local_port and local_port > 0 then
      data_network:send_value(pos, dir, local_port, value)
    end
  end
end

function yatm_data_logic.emit_output_data_value(pos, dl, options)
  options = options or {}
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids(pos)

  local did_output = false

  if dl and #dl > 0 then
    for _, dir in ipairs(Directions.DIR6) do
      if options.output_vector then
        for i = 1,options.output_vector do
          local local_port = meta:get_int("output_" .. dir .. "_" .. i)

          if local_port and local_port > 0 then
          --[[print("emit_output_data", minetest.pos_to_string(pos),
                                    data_name,
                                    local_port,
                                    dump(dl),
                                    dump(sub_network_ids))]]

            data_network:send_value(pos, dir, local_port, dl)
            did_output = true
          else
            --print("port not set", minetest.pos_to_string(pos), data_name, dir)
          end
        end
      else
        local local_port = meta:get_int("output_" .. dir)

        if local_port and local_port > 0 then
          --[[print("emit_output_data", minetest.pos_to_string(pos),
                                    data_name,
                                    local_port,
                                    dump(dl),
                                    dump(sub_network_ids))]]

          data_network:send_value(pos, dir, local_port, dl)
          did_output = true
        else
          --print("port not set", minetest.pos_to_string(pos), data_name, dir)
        end
      end
    end
  else
    --print("no data", minetest.pos_to_string(pos), data_name, dump(dl))
  end

  return did_output
end

function yatm_data_logic.emit_output_data(pos, data_name, options)
  local meta = minetest.get_meta(pos)
  local value = meta:get_string("data_" .. data_name)
  return yatm_data_logic.emit_output_data_value(pos, value, options)
end

--
-- Emit value in all directions
--
function yatm_data_logic.emit_value(pos, local_port, value)
  local did_output = false
  for _, dir in ipairs(Directions.DIR6) do
    did_output = data_network:send_value(pos, dir, local_port, value) or
                 did_output
  end
  return did_output
end

local function set_vector(meta, basename, dir, value, vector, changed)
  local items = string_split(value, ",")

  for i = 1,vector do
    local base_value = meta:get_int(basename .. "_" .. dir .. "_" .. i)
    local new_value = tonumber(items[i]) or base_value

    if new_value ~= base_value then
      if not changed[dir] then
        changed[dir] = {}
      end
      changed[dir][i] = {new_value, base_value}
      meta:set_int(basename .. "_" .. dir .. "_" .. i, new_value)
    end
  end
end

--
-- Options:
--   input_vector :: integer - tells the function that any values obtained are a vector
--                             and should be assigned to multiple fields in the meta
--   output_vector :: integer - tells the function that any values obtained are a vector
--                              and should be assigned to multiple fields in the meta
function yatm_data_logic.handle_io_port_fields(pos, fields, meta, mode, options)
  options = options or {}
  -- TODO: lint port values using these
  assert(pos, "expected a position")
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local attached_colors = data_network:get_attached_colors(pos)

  -- Ports tab
  local inputs_changed = {}
  local outputs_changed = {}

  local has_input = mode == "io" or mode == "i"
  local has_output = mode == "io" or mode == "o"

  for _, dir in ipairs(Directions.DIR6) do
    local input_value = fields["input_" .. dir]
    local output_value = fields["output_" .. dir]

    if has_input then
      if input_value then
        if options.input_vector then
          set_vector(meta, "input", dir, input_value, options.input_vector, inputs_changed)
        else
          input_value = tonumber(input_value)
          local old_input_value = meta:get_int("input_" .. dir)
          if input_value ~= old_input_value then
            inputs_changed[dir] = {input_value, old_input_value}
            meta:set_int("input_" .. dir, input_value)
          end
        end
      else
        for i=1,8 do
          local input_bit = fields["input_"..dir.."_bit_"..i]
          if input_bit then
            local old_input_value = meta:get_int("input_" .. dir)
            input_value = toggle_bit(old_input_value, i-1)

            if input_value ~= old_input_value then
              inputs_changed[dir] = {input_value, old_input_value}
              meta:set_int("input_" .. dir, input_value)
            end
          end
        end
      end
    end

    if has_output then
      if output_value then
        if options.output_vector then
          set_vector(meta, "output", dir, output_value, options.output_vector, outputs_changed)
        else
          output_value = tonumber(output_value)
          local old_output_value = meta:get_int("output_" .. dir)
          if output_value ~= old_output_value then
            outputs_changed[dir] = {output_value, old_output_value}
            meta:set_int("output_" .. dir, output_value)
          end
        end
      else
        for i=1,8 do
          local output_bit = fields["output_"..dir.."_bit_"..i]
          if output_bit then
            local old_output_value = meta:get_int("output_" .. dir)
            output_value = toggle_bit(old_output_value, i-1)

            if output_value ~= old_output_value then
              outputs_changed[dir] = {output_value, old_output_value}
              meta:set_int("output_" .. dir, output_value)
            end
          end
        end
      end
    end
  end

  return inputs_changed, outputs_changed
end

function yatm_data_logic.handle_port_matrix_fields(pos, fields, meta, options)
  local result = {}
  for _, dir in ipairs(Directions.DIR6) do
    for section_index, section in ipairs(options.sections) do
      for port_id = 1, section.port_count do
        local port_name = section.port_names[port_id] or port_id
        local field_name = section.name .. "_" .. dir .. "_" .. port_name

        if fields[field_name] then
          local old_value = meta:get_int(field_name)
          local value = tonumber(fields[field_name])

          if old_value ~= value then
            meta:set_int(field_name, value)
            if not result[section.name] then
              result[section.name] = {}
            end
            result[section.name][port_name] = value
          end
        end
      end
    end
  end
  return result
end
