local data_network = assert(yatm.data_network)

function yatm_data_logic.unmark_all_receive(pos)
  assert(pos, "expected a position")
  data_network:unmark_ready_to_receive(pos, 0, 0)
end

function yatm_data_logic.bind_input_port(pos, local_port, status)
  for _, dir in ipairs(yatm_core.DIR6) do
    data_network:mark_ready_to_receive(pos, dir, local_port, status or "active")
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

function yatm_data_logic.emit_port_value(pos, port_prefix, port_name, value)
  local meta = minetest.get_meta(pos)
  local sub_network_ids = data_network:get_sub_network_ids(pos)

  for _, dir in ipairs(yatm_core.DIR6) do
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
  local value = meta:get_string("data_" .. data_name)
  yatm_data_logic.emit_output_data_value(pos, value, options)
end

--
-- Emit value in all directions
--
function yatm_data_logic.emit_value(pos, local_port, value)
  for _, dir in ipairs(yatm_core.DIR6) do
    data_network:send_value(pos, dir, local_port, value)
  end
end

--
-- @type options :: {
--   width = float,
--   sections = [
--     {
--        name = string, -- lower case string will be prefixed on the port names
--        label = string, -- descriptive label of the section
--        cols = integer, -- how many colunms are allowed in this section
--        port_count = integer, -- how many ports does this section have
--        port_names = [string], -- the port names
--        port_labels = [string], -- the descriptive labels of each port
--     }
--   ]
-- }
-- @spec yatm_data_logic.get_port_matrix_formspec(vector, MetaRef, options)
function yatm_data_logic.get_port_matrix_formspec(pos, meta, options)
  options = options or {}
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local attached_colors = data_network:get_attached_colors(pos)

  local col_width = options.width or 8
  local i = 1

  local formspec = ""

  -- 0.5 is the border size (0.25 on each side)
  local sections_width = (col_width - 0.5) / #options.sections

  for _, dir in ipairs(yatm_core.DIR6) do
    local sub_network_id = sub_network_ids[dir]
    if sub_network_id then
      local name = minetest.formspec_escape(yatm_core.dir_to_string(dir) .. " - " ..
                                            (attached_colors[dir] or "N/A") .. " - " ..
                                            sub_network_id)

      formspec =
        formspec ..
        "label[0.25," .. i .. ";" .. minetest.formspec_escape(name) .. "]"

      i = i + 1

      local max_section_y = 0

      for section_index, section in ipairs(options.sections) do
        local section_y = i
        local section_x = 0.25 + sections_width * (section_index - 1)

        if section.label then
          formspec =
            formspec ..
            "label[" .. section_x .. "," .. section_y .. ";" .. minetest.formspec_escape(section.label) .. "]"

          section_y = section_y + 1
        end

        local section_col_width = sections_width / section.cols

        for port_id = 1, section.port_count do
          local x = section_x + ((port_id - 1) % section.cols) * section_col_width
          local y = section_y + math.floor((port_id - 1) / section.cols)

          local field_name = section.name .. "_" .. dir .. "_" .. (section.port_names[port_id] or port_id)
          local field_label = section.port_labels[port_id] or field_name

          formspec =
            formspec ..
            "field[" .. x .. "," .. y ..
                   ";" .. section_col_width .. ",1;" .. field_name ..
                   ";" .. minetest.formspec_escape(field_label) ..
                   ";" .. meta:get_int(field_name) .. "]"
        end

        max_section_y = math.max(max_section_y, section_y)
      end

      i = max_section_y + 1
    end
  end

  return formspec
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

function yatm_data_logic.handle_port_matrix_fields(pos, fields, meta, options)
  for _, dir in ipairs(yatm_core.DIR6) do
    for section_index, section in ipairs(options.sections) do
      for port_id = 1, section.port_count do
        local field_name = section.name .. "_" .. dir .. "_" .. (section.port_names[port_id] or port_id)

        if fields[field_name] then
          local value = tonumber(fields[field_name])

          meta:set_int(field_name, value)
        end
      end
    end
  end
end
