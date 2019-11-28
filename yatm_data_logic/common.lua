local data_network = assert(yatm.data_network)

function yatm_data_logic.unmark_all_receive(pos)
  assert(pos, "expected a position")
  data_network:unmark_ready_to_receive(pos, 0, 0)
end

function yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids_by_color(pos)

  for _, dir in ipairs(yatm_core.DIR6) do
    local local_port = meta:get_int("input_" .. dir)

    if local_port and local_port > 0 then
      data_network:mark_ready_to_receive(pos, dir, local_port, "active")
    end
  end
end

function yatm_data_logic.emit_output_data(pos, data_name)
  local meta = minetest.get_meta(pos)

  local sub_network_ids = data_network:get_sub_network_ids(pos)

  local dl = meta:get_string("data_" .. data_name)
  if dl and #dl > 0 then
    for _, dir in ipairs(yatm_core.DIR6) do
      local local_port = meta:get_int("output_" .. dir)

      if local_port and local_port > 0 then
        print("emit_output_data", minetest.pos_to_string(pos),
                                  data_name,
                                  local_port,
                                  dump(dl),
                                  dump(sub_network_ids))

        data_network:send_value(pos, dir, local_port, dl)
      else
        print("port not set", minetest.pos_to_string(pos), data_name, dir)
      end
    end
  else
    print("no data", minetest.pos_to_string(pos), data_name, dump(dl))
  end
end

function yatm_data_logic.get_io_port_formspec(pos, meta, mode)
  mode = mode or "io"
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local attached_colors = data_network:get_attached_colors(pos)

  local col_width = 8

  if mode == "io" then
    col_width = 4
  end

  local inputs =
    "label[0,1;Inputs]"

  local outputs
  local output_x = 0
  if mode == "io" then
    outputs = "label[4,1;Outputs]"
    output_x = 4
  elseif mode == "o" then
    outputs = "label[0,1;Outputs]"
  end

  local i = 2

  for _, dir in ipairs(yatm_core.DIR6) do
    if sub_network_ids[dir] then
      if mode == "io" or mode == "i" then
        inputs =
          inputs ..
          "field[0.25," .. i .. ";" .. col_width .. ",1;input_" .. dir .. ";" .. yatm_core.dir_to_string(dir) .. ";" .. meta:get_int("input_" .. dir) .. "]"
      end

      if mode == "io" or mode == "o" then
        outputs =
          outputs ..
          "field[" .. (output_x + 0.25) ..  "," .. i .. ";" .. col_width .. ",1;output_" .. dir .. ";" .. yatm_core.dir_to_string(dir) .. ";" .. meta:get_int("output_" .. dir) .. "]"
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

function yatm_data_logic.handle_io_port_fields(pos, fields, meta, mode)
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

    if (mode == "io" or mode == "i") and input_value then
      input_value = tonumber(input_value)
      local old_input_value = meta:get_int("input_" .. dir)
      if input_value ~= old_input_value then
        inputs_changed[dir] = {input_value, old_input_value}
        meta:set_int("input_" .. dir, input_value)
      end
    end

    if (mode == "io" or mode == "o") and output_value then
      output_value = tonumber(output_value)
      local old_output_value = meta:get_int("output_" .. dir)
      if output_value ~= old_output_value then
        outputs_changed[dir] = {output_value, old_output_value}
        meta:set_int("output_" .. dir, output_value)
      end
    end
  end

  return inputs_changed
end
