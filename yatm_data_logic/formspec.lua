--
-- DATA formspec components
--
local DataNetwork = assert(yatm.DataNetwork)
local data_network = assert(yatm.data_network)
local Directions = assert(foundation.com.Directions)
local fspec = assert(foundation.com.formspec.api)

-- @namespace yatm_data_logic

local BUTTONS_BY_BIT = {
  {
    bit = 1,
    color = "red",
  },
  {
    bit = 2,
    color = "green",
  },
  {
    bit = 3,
    color = "blue",
  },
  {
    bit = 4,
    color = "cyan",
  },
  {
    bit = 5,
    color = "yellow",
  },
  {
    bit = 6,
    color = "magenta",
  },
  {
    bit = 7,
    color = "white",
  },
  {
    bit = 8,
    color = "black",
  },
}

-- The formspec should be able to fit 2 columns of 8 bit buttons
-- That requires (8+1)*2, where 1 is the item_image used to identify the port color,
-- 8 is the width of the buttons
yatm_data_logic.FORMSPEC_SIZE = {w = 20, h = 15}

function yatm_data_logic.layout_formspec(w, h)
  local formspec =
    fspec.formspec_version(4) ..
    fspec.size(w or yatm_data_logic.FORMSPEC_SIZE.w, h or yatm_data_logic.FORMSPEC_SIZE.h)

  return formspec
end

-- Section Properties
--   * `name` - lower case string will be prefixed on the port names
--   * `label` - descriptive label of the section
--   * `cols` - how many colunms are allowed in this section
--   * `port_count` - how many ports does this section have
--   * `port_names` - the port names
--   * `port_labels` - the descriptive labels of each port
--
-- @type PortOptions: {
--   width: Float,
--   sections: [
--     {
--        name: String,
--        label: String,
--        cols: Integer,
--        port_count: Integer,
--        port_names: [String],
--        port_labels: [String],
--     }
--   ]
-- }
--
-- @spec yatm_data_logic.get_port_matrix_formspec(Vector3, MetaRef, PortOptions): String
function yatm_data_logic.get_port_matrix_formspec(pos, meta, options)
  options = options or {}
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local attached_colors = data_network:get_attached_colors(pos)

  local col_width = options.width or yatm_data_logic.FORMSPEC_SIZE.w
  local i = 1

  local formspec = ""

  -- 0.5 is the border size (0.25 on each side)
  local sections_width = (col_width - 0.5) / #options.sections

  for _, dir in ipairs(Directions.DIR6) do
    local sub_network_id = sub_network_ids[dir]
    if sub_network_id then
      local name = minetest.formspec_escape(Directions.dir_to_string(dir) .. " - " ..
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

  local width = options.width or yatm_data_logic.FORMSPEC_SIZE.w
  local col_width = width

  if mode == "io" then
    col_width = math.floor(col_width / 2)
  end

  local dx = options.x or 0
  local dy = options.y or 0

  local inputs =
    fspec.label(dx, dy-0.25, "Inputs")

  local outputs
  local output_dx = dx

  if mode == "io" then
    outputs = fspec.label(dx + col_width, dy-0.25, "Outputs")
    output_dx = dx + col_width
  elseif mode == "o" then
    outputs = fspec.label(dx, dy-0.25, "Outputs")
  end

  local row = 0

  local show_input = mode == "io" or mode == "i"
  local show_output = mode == "io" or mode == "o"

  local item_size = 1
  local y = dy + row * 2

  for _, dir in ipairs(Directions.DIR6) do
    local sub_network_id = sub_network_ids[dir]
    if sub_network_id then
      local dircode = Directions.dir_to_code(dir):lower()
      local border_image_name = "yatm_item_border_"..dircode..".png"

      local item_name
      local color = attached_colors[dir]
      local bits = 8

      if color then
        item_name = "yatm_data_network:data_cable_bus_" .. color
        --item_name = "yatm_data_network:data_cable_bus_bracket_cross_" .. color
        local range = DataNetwork.COLOR_RANGE[color].range

        if range == DataNetwork.PORT_RANGE then
          bits = 4
        end
      end

      local label = Directions.dir_to_string(dir) .. " - " .. sub_network_id

      if show_input then
        local input_field_name = "input_"..dir

        local button_x = dx + item_size

        inputs =
          inputs ..
          fspec.item_image(dx, y, item_size, item_size, item_name) ..
          fspec.image(dx, y, item_size, item_size, border_image_name)

        -- if input is vector, then pull multiple values instead
        if options.input_vector then
          outputs =
            outputs ..
            yatm_data_logic.render_io_port_vector(
              button_x, y, col_width-item_size, 1,
              bits, options.input_vector, input_field_name, label,
              meta
            )
        else
          local default_value = meta:get_int(input_field_name)

          inputs =
            inputs ..
            yatm_data_logic.render_multibit_buttons_formspec(
              button_x, y, 1, 1, bits, input_field_name, default_value)
        end
      end

      if show_output then
        local output_field_name = "output_"..dir

        local button_x = output_dx + item_size

        outputs =
          outputs ..
          fspec.item_image(output_dx, y, item_size, item_size, item_name) ..
          fspec.image(output_dx, y, item_size, item_size, border_image_name)

        -- if output is vector, then pull multiple values instead
        if options.output_vector then
          outputs =
            outputs ..
            yatm_data_logic.render_io_port_vector(
              button_x, y, col_width-item_size, 1,
              bits, options.output_vector, output_field_name, label,
              meta
            )
        else
          local default_value = meta:get_int(output_field_name)

          outputs =
            outputs ..
            yatm_data_logic.render_multibit_buttons_formspec(
              button_x, y, 1, 1, bits, output_field_name, default_value)
        end
      end

      row = row + 1
      y = dy + row * 2
    end
  end

  local r = {
    x = dx,
    y = y,
    w = width,
    h = row + 1
  }

  if mode == "io" then
    return inputs .. outputs, r
  elseif mode == "o" then
    return outputs, r
  elseif mode == "i" then
    return inputs, r
  end
end

function yatm_data_logic.render_io_port_vector(x, y, w, h, bit_count, vector_length, port_prefix, label, meta)
  local single_field = false

  local formspec = ""

  if single_field then
    local values = {}

    for index = 1,vector_length do
      values[index] = meta:get_int(port_prefix .. "_" .. index)
    end

    local vector_value = table.concat(values, ",")

    formspec =
      formspec ..
      fspec.field_area(x, y, w, h,
                       port_prefix, label,
                       default_value)
  else
    local selected_port_index = meta:get_int(port_prefix.."_selected_port")
    selected_port_index = math.max(math.min(selected_port_index, vector_length), 1)

    local default_value = meta:get_int(port_prefix.."_"..selected_port_index)

    local texture_name = "yatm_small_colored_button_white.off.png"
    local texture_name_alt = "yatm_small_colored_button_white.on.png"

    local cw = w/vector_length

    formspec =
      formspec ..
      yatm_data_logic.render_multibit_buttons_formspec(
        x, y, 1, 1, bit_count, port_prefix.."_"..selected_port_index, default_value)

    for index = 1,vector_length do
      local is_selected = selected_port_index == index
      local a, b = texture_name, texture_name_alt
      if is_selected then
        a, b = b, a
      end

      formspec =
        formspec ..
        fspec.image_button(x + (index-1) * cw, y+1, cw, h/2,
                           a,
                           port_prefix.."_selected_port",
                           tostring(index), -- name
                           true, -- Noclip
                           false,
                           b)
    end
  end

  return formspec
end

function yatm_data_logic.render_multibit_buttons_formspec(x, y, w, h, length, field_prefix, value)
  local formspec = ""

  local rolling_value = value

  for i=1,length do
    local bit = rolling_value % 2
    rolling_value = math.floor(rolling_value / 2)

    local button_spec = BUTTONS_BY_BIT[i]
    local texture_name = "yatm_wide_switch_" .. button_spec.color .. ".down.png"
    local texture_name_alt = "yatm_wide_switch_" .. button_spec.color .. ".up.png"

    -- flip the texture states if the bit is set
    if bit == 1 then
      texture_name = texture_name_alt
    else
      texture_name_alt = texture_name
    end

    local button_x = x + length - i * w

    --local name = bit
    local name = ''

    formspec =
      formspec ..
      fspec.image_button(button_x, y, w, h,
                         texture_name,
                         field_prefix.."_bit_"..i,
                         name, -- name
                         true, -- Noclip
                         false,
                         texture_name_alt)
  end

  return formspec
end
