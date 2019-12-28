local data_network = assert(yatm.data_network)

function yatm_data_logic.unmark_all_receive(pos)
  assert(pos, "expected a position")
  data_network:unmark_ready_to_receive(pos, 0, 0)
end

--
-- Marks all input ports as active, that is to ALWAYS receive data
--
function yatm_data_logic.mark_all_inputs_for_active_receive(pos, options)
  assert(pos, "requires a position")
  options = options or {}
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids_by_color(pos)

  for _, dir in ipairs(yatm_core.DIR6) do
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
function yatm_data_logic.emit_output_data_vector(pos, vector_value, options)
  options = options or {}
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids(pos)

  if vector_value and #vector_value > 0 then
    for _, dir in ipairs(yatm_core.DIR6) do
      if options.output_vector then
        for i = 1,options.output_vector do
          local local_port = meta:get_int("output_" .. dir .. "_" .. i)

          if local_port and local_port > 0 then
            local char = string.sub(vector_value, i, i)
            data_network:send_value(pos, dir, local_port, char)
          end
        end
      else
        local local_port = meta:get_int("output_" .. dir)

        if local_port and local_port > 0 then
          data_network:send_value(pos, dir, local_port, vector_value)
        end
      end
    end
  end
end

function yatm_data_logic.emit_output_data_value(pos, dl, options)
  options = options or {}
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids(pos)

  if dl and #dl > 0 then
    for _, dir in ipairs(yatm_core.DIR6) do
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
        else
          --print("port not set", minetest.pos_to_string(pos), data_name, dir)
        end
      end
    end
  else
    --print("no data", minetest.pos_to_string(pos), data_name, dump(dl))
  end
end

function yatm_data_logic.emit_output_data(pos, data_name, options)
  local meta = minetest.get_meta(pos)
  local dl = meta:get_string("data_" .. data_name)
  yatm_data_logic.emit_output_data_value(pos, dl, options)
end

--
-- Emit value in all directions
--
function yatm_data_logic.emit_value(pos, local_port, value)
  for _, dir in ipairs(yatm_core.DIR6) do
    data_network:send_value(pos, dir, local_port, value)
  end
end

function yatm_data_logic.get_io_port_matrix_formspec(pos, meta, mode, options)
  options = options or {}
  mode = mode or "io"
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local attached_colors = data_network:get_attached_colors(pos)

  -- these are port counts PER direction
  options.input_port_cols = options.input_port_cols or 1
  options.input_port_count = options.input_port_count or 1
  options.output_port_cols = options.output_port_cols or 1
  options.output_port_count = options.output_port_count or 1

  local col_width = options.width or 8
  if mode == "io" then
    col_width = math.floor(col_width / 2)
  end

  local input_col_width = math.floor(col_width / options.input_port_cols)
  local output_col_width = math.floor(col_width / options.output_port_cols)

  local inputs =
    "label[0,1;Inputs]"

  if mode == "io" then
    outputs = "label[" .. col_width .. ",1;Outputs]"
    output_x = col_width
  elseif mode == "o" then
    outputs = "label[0,1;Outputs]"
  end

  local i = 2

  for _, dir in ipairs(yatm_core.DIR6) do
    local sub_network_id = sub_network_ids[dir]
    if sub_network_id then
      local name = minetest.formspec_escape(yatm_core.dir_to_string(dir) .. " - " ..
                                            (attached_colors[dir] or "N/A") .. " - " ..
                                            sub_network_id)

      if mode == "io" or mode == "i" then
        for input_port_id = 1,options.input_port_count do
          local x = (0.25) + (input_port_id % options.input_port_cols) * input_col_width
          local y = i + math.floor(input_port_id / options.input_port_cols)

          inputs =
            inputs ..
            "field[" .. x .. "," .. y ..
                   ";" .. col_width .. ",1;" .. field_name ..
                   ";" .. name ..
                   ";" .. meta:get_int(field_name) .. "]"
        end
      end

      if mode == "io" or mode == "o" then
        for output_port_id = 1,options.output_port_count do
          local x = (output_x + 0.25) + (output_port_id % options.output_port_cols) * output_col_width
          local y = i + math.floor(output_port_id / options.output_port_cols)

          local field_name = "output_" .. dir .. "_" ..  output_port_id

          outputs =
            outputs ..
            "field[" .. x ..  "," .. y ..
                   ";" .. col_width .. ",1;" .. field_name ..
                   ";" .. name ..
                   ";" .. meta:get_int(field_name) .. "]"
        end
      end

      i = i + 1
    end
  end

  if mode == "io" then
    return inputs .. outputs
  elseif mode == "o" then
    return outputs
  elseif mode == "i" then
    return inputs
  end
end

function yatm_data_logic.get_io_port_formspec(pos, meta, mode, options)
  options = options or {}
  mode = mode or "io"
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local attached_colors = data_network:get_attached_colors(pos)

  local col_width = options.width or 8

  if mode == "io" then
    col_width = math.floor(col_width / 2)
  end

  local inputs =
    "label[0,1;Inputs]"

  local outputs
  local output_x = 0
  if mode == "io" then
    outputs = "label[" .. col_width .. ",1;Outputs]"
    output_x = col_width
  elseif mode == "o" then
    outputs = "label[0,1;Outputs]"
  end

  local i = 2

  for _, dir in ipairs(yatm_core.DIR6) do
    if sub_network_ids[dir] then
      local sub_network_id = sub_network_ids[dir]

      local name = yatm_core.dir_to_string(dir) .. " - " ..
                   (attached_colors[dir] or "N/A") .. " - " ..
                   sub_network_id

      if mode == "io" or mode == "i" then
        local default_value
        -- if input is vector, then pull multiple values instead
        if options.input_vector then
          local values = {}

          for i = 1,options.input_vector do
            values[i] = meta:get_int("input_" .. dir .. "_" .. i)
          end

          default_value = minetest.formspec_escape(table.concat(values, ","))
        else
          default_value = meta:get_int("input_" .. dir)
        end

        inputs =
          inputs ..
          "field[0.25," .. i ..
                 ";" .. col_width .. ",1;input_" .. dir ..
                 ";" .. name ..
                 ";" .. default_value .. "]"
      end

      if mode == "io" or mode == "o" then
        local default_value
        -- if output is vector, then pull multiple values instead
        if options.output_vector then
          local values = {}

          for i = 1,options.output_vector do
            values[i] = meta:get_int("output_" .. dir .. "_" .. i)
          end

          default_value = minetest.formspec_escape(table.concat(values, ","))
        else
          default_value = meta:get_int("output_" .. dir)
        end

        outputs =
          outputs ..
          "field[" .. (output_x + 0.25) ..  "," .. i ..
                 ";" .. col_width .. ",1;output_" .. dir ..
                 ";" .. name ..
                 ";" .. default_value .. "]"
      end

      i = i + 1
    end
  end

  if mode == "io" then
    return inputs .. outputs
  elseif mode == "o" then
    return outputs
  elseif mode == "i" then
    return inputs
  end
end

local function set_vector(meta, basename, dir, value, vector, changed)
  local items = yatm_core.string_split(value, ",")

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

  for _, dir in ipairs(yatm_core.DIR6) do
    local input_value = fields["input_" .. dir]
    local output_value = fields["output_" .. dir]

    if input_value and (mode == "io" or mode == "i") then
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
    end

    if output_value and (mode == "io" or mode == "o") then
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
    end
  end

  return inputs_changed, outputs_changed
end
