--
-- Arithmetic Data Hubs
--
-- Each type has 2 modes:
--   Normal mode - input streams are treated as single numbers and will be affected by overflows
--   Vector mode - input streams are vectors, each byte in the stream is a single
--                 number and overflow is treated as a loop around
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local string_hex_escape = assert(foundation.com.string_hex_escape)
local string_split = assert(foundation.com.string_split)
local table_merge = assert(foundation.com.table_merge)
local table_copy = assert(foundation.com.table_copy)
local is_table_empty = assert(foundation.com.is_table_empty)
local list_get_next = assert(foundation.com.list_get_next)
local Directions = assert(foundation.com.Directions)
local data_network = assert(yatm.data_network)
local fspec = assert(foundation.com.formspec.api)
local data_math = assert(yatm_data_logic.data_math)

local OPERAND_NAMES = {"A", "B"}
local OPERATORS = {
  "identity",
  "add",
  "subtract",
  "multiply",
  "divide",
  "modulo",
  "max",
  "min",
}

local OPERATOR_SYMBOL = {
  identity = ".",
  add = "+",
  subtract = "-",
  multiply = "*",
  divide = "/",
  modulo = "%",
  max = "mx",
  min = "mn",
}

local OPERATOR_NODES_LIST = {}
local OPERATOR_VECTOR_NODES_LIST = {}
local OPERATOR_NODE_TO_STAMP = {}
local NODE_NAME_TO_OPERATOR = {}
local NODE_NAME_TO_NORMAL_OPERATOR = {}
local NODE_NAME_TO_VECTOR_OPERATOR = {}
local OPERATOR_TO_NODE_NAMES = {}

local CONFIG = {
  -- determines how long a number can be in bytes this affects normal operations
  byte_size = 16,
  -- the maximum number of elements expected in a vector type
  vector_size = 16,
  -- how many bytes does each element in the vector occupy
  vector_element_byte_size = 1,
}

for index,operator_name in ipairs(OPERATORS) do
  OPERATOR_NODES_LIST[index] = "yatm_data_logic:data_arith_" .. operator_name
  OPERATOR_VECTOR_NODES_LIST[index] = "yatm_data_logic:data_arith_" .. operator_name .. "_vector"
  OPERATOR_NODE_TO_STAMP[OPERATOR_NODES_LIST[index]] = "yatm_data_arith_stamps_" .. operator_name .. ".png"
  OPERATOR_NODE_TO_STAMP[OPERATOR_VECTOR_NODES_LIST[index]] = "yatm_data_arith_stamps_" .. operator_name .. ".png"

  NODE_NAME_TO_OPERATOR[OPERATOR_NODES_LIST[index]] = operator_name
  NODE_NAME_TO_OPERATOR[OPERATOR_VECTOR_NODES_LIST[index]] = operator_name
  NODE_NAME_TO_NORMAL_OPERATOR[OPERATOR_NODES_LIST[index]] = operator_name
  NODE_NAME_TO_VECTOR_OPERATOR[OPERATOR_VECTOR_NODES_LIST[index]] = operator_name

  OPERATOR_TO_NODE_NAMES[operator_name] = {
    normal = OPERATOR_NODES_LIST[index],
    vector = OPERATOR_VECTOR_NODES_LIST[index],
  }
end

local function get_input_value(meta, dir)
  return meta:get_string("input_value_" .. dir)
end

local function set_input_value(meta, dir, value)
  meta:set_string("input_value_" .. dir, value)
end

local function get_input_values(pos)
  local sub_network_ids = data_network:get_sub_network_ids(pos)
  local meta = minetest.get_meta(pos)
  local result = {}

  for _, dir in ipairs(Directions.DIR6) do
    if sub_network_ids[dir] then
      local port = yatm_data_logic.get_matrix_port(pos, "port", "input", dir)
      if port > 0 then
        local value = get_input_value(meta, dir)
        result[dir] = string_hex_unescape(value)
      end
    end
  end

  return result
end

local function get_operand_value(meta, place)
  local operand_name = meta:get_string("operand_" .. place)
  if operand_name == "B" then
    return meta:get_string("operand_b_value")
  else
    return meta:get_string("operand_a_value")
  end
end

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    local meta = minetest.get_meta(pos)

    local needs_refresh = false
    local should_exec = false

    if should_exec then
      local left = get_operand_value(meta, "left")
      local right = get_operand_value(meta, "right")
      local new_value = self:calculate(pos, node, left, right)

      if meta:get_string("last_value") ~= new_value then
        meta:set_string("last_value", new_value)
        needs_refresh = true
      end
    end

    if needs_refresh then
      yatm.queue_refresh_infotext(pos, node)
    end
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
                component = "field",
                type = "string",
                label = "Operand A Value",
                name = "operand_a_value",
                meta = true,
              },
              {
                component = "field",
                type = "string",
                label = "Operand B Value",
                name = "operand_b_value",
                meta = true,
              },
            },
          },
          {
            component = "render",
            render = function (self, rect, pos, player, pointed_thing, assigns)
              local meta = minetest.get_meta(pos)
              local node = minetest.get_node(pos)

              local operator_image = OPERATOR_NODE_TO_STAMP[node.name]

              local image_a = "yatm_data_arith_stamps_a.png"
              local image_b = "yatm_data_arith_stamps_b.png"

              local operand_left_image
              local operand_right_image

              local vector_image = "yatm_data_arith_stamps_blank.png"

              if NODE_NAME_TO_VECTOR_OPERATOR[node.name] then
                vector_image = "yatm_data_arith_stamps_vector_blank.png"
              end

              local current_operand_left = meta:get_string("operand_left")
              local current_operand_right = meta:get_string("operand_right")

              if current_operand_left == "B" then
                operand_left_image = image_b
              else
                operand_left_image = image_a
              end

              if current_operand_right == "B" then
                operand_right_image = image_b
              else
                operand_right_image = image_a
              end

              local formspec = ""

              formspec =
                formspec ..
                fspec.label(rect.x, rect.y+0.5, "Operation Config")

              rect.y = rect.y + 0.75
              rect.h = rect.h - 0.75

              formspec =
                formspec ..
                fspec.image_button(rect.x, rect.y, 1, 1,
                  vector_image, "vector_mode_change", "", false, false, vector_image) ..
                fspec.image_button(rect.x + 1, rect.y, 1, 1,
                  operand_left_image, "operand_left_change", "", false, false, operand_left_image) ..
                fspec.image_button(rect.x + 2, rect.y, 1, 1,
                  operator_image, "operator_change", "", false, false, operator_image) ..
                fspec.image_button(rect.x + 3, rect.y, 1, 1,
                  operand_right_image, "operand_right_change", "", false, false, operand_right_image) ..
                fspec.image(rect.x + 4, rect.y, 1, 1, "yatm_data_arith_stamps_down_equal.png") ..
                fspec.image(rect.x + 5, rect.y, 1, 1, "yatm_data_arith_stamps_down_c.png")

              rect.y = rect.y + 1
              rect.h = rect.h - 1

              return formspec, rect
            end,
          },
        },
      },
    },
  },

  receive_programmer_fields = {
    tabbed = true,
    tabs = {
      {
        components = {
          {
            component = "io_ports",
            mode = "io",
          },
        },
      },
      {
        components = {
          {
            component = "field",
            name = "operand_a_value",
            type = "string",
            meta = true,
          },
          {
            component = "field",
            name = "operand_b_value",
            type = "string",
            meta = true,
          },
          {
            component = "handle",
            handle = function (_self, pos, meta, fields, assigns)
              local should_refresh = false
              if fields["vector_mode_change"] then
                local node = minetest.get_node(pos)

                local operator_name = NODE_NAME_TO_OPERATOR[node.name]
                if operator_name then
                  local data = OPERATOR_TO_NODE_NAMES[operator_name]

                  if data then
                    if data.normal == node.name then
                      node.name = data.vector
                      minetest.swap_node(pos, node)
                      should_refresh = true
                    elseif data.vector == node.name then
                      node.name = data.normal
                      minetest.swap_node(pos, node)
                      should_refresh = true
                    end
                  end
                end
              end

              if fields["operand_left_change"] then
                meta:set_string("operand_left", list_get_next(OPERAND_NAMES, meta:get_string("operand_left")))
                should_refresh = true
              end

              if fields["operand_right_change"] then
                meta:set_string("operand_right", list_get_next(OPERAND_NAMES, meta:get_string("operand_right")))
                should_refresh = true
              end

              if fields["operator_change"] then
                local node = minetest.get_node(pos)

                local next_node = list_get_next(OPERATOR_NODES_LIST, node.name)

                if next_node then
                  node.name = next_node

                  minetest.swap_node(pos, node)
                end
                should_refresh = true
              end

              return should_refresh
            end,
          }
        }
      }
    }
  },
}

yatm.register_stateful_node("yatm_data_logic:data_arith", {
  base_description = "DATA Arithmetic",

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

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    local node = minetest.get_node(pos)

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
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    local operator = OPERATOR_SYMBOL[NODE_NAME_TO_OPERATOR[node.name]]

    local infotext =
      string_split(nodedef.description, "\n")[1] .. "\n" ..
      "Last Output: " .. meta:get_string("last_value") .. "\n" ..
      "Operation: " .. meta:get_string("operand_left") .. " " .. operator .. " " ..  meta:get_string("operand_right") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  --
  -- Normal Mode
  --
  identity = {
    description = "DATA Arithmetic [Identity]\nReturns data unchanged, it may replace any missing entries with other data from inputs",

    codex_entry_id = "yatm_data_logic:data_arith_identity",

    tiles = {
      "yatm_data_arith_top.identity.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.identity(left, right, CONFIG)
      end,
    }),
  },

  add = {
    description = "DATA Arithmetic [Addition]\nAdds all input data",

    codex_entry_id = "yatm_data_logic:data_arith_add",

    tiles = {
      "yatm_data_arith_top.add.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.add(left, right, CONFIG)
      end,
    }),
  },

  subtract = {
    description = "DATA Arithmetic [Subtraction]\nSubtracts input data",

    codex_entry_id = "yatm_data_logic:data_arith_subtract",

    tiles = {
      "yatm_data_arith_top.subtract.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.subtract(left, right, CONFIG)
      end,
    }),
  },

  multiply = {
    description = "DATA Arithmetic [Multiplication]\nMultiplies input data",

    codex_entry_id = "yatm_data_logic:data_arith_multiply",

    tiles = {
      "yatm_data_arith_top.multiply.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.multiply(left, right, CONFIG)
      end,
    }),
  },

  divide = {
    description = "DATA Arithmetic [Division]\nDivide Arithmetic",

    codex_entry_id = "yatm_data_logic:data_arith_divide",

    tiles = {
      "yatm_data_arith_top.divide.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.divide(left, right, CONFIG)
      end,
    }),
  },

  modulo = {
    description = "DATA Arithmetic [Modulo]\nModulo Arithmetic",

    codex_entry_id = "yatm_data_logic:data_arith_modulo",

    tiles = {
      "yatm_data_arith_top.modulo.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.modulo(left, right, CONFIG)
      end,
    }),
  },

  max = {
    description = "DATA Arithmetic [Max]",

    codex_entry_id = "yatm_data_logic:data_arith_max",

    tiles = {
      "yatm_data_arith_top.max.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.max(left, right, CONFIG)
      end,
    }),
  },

  min = {
    description = "DATA Arithmetic [Min]",

    codex_entry_id = "yatm_data_logic:data_arith_min",

    tiles = {
      "yatm_data_arith_top.min.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.min(left, right, CONFIG)
      end,
    }),
  },
  --
  -- Vector Mode
  --
  identity_vector = {
    description = "DATA Arithmetic [Identity Vector]\nReturns data unchanged",

    codex_entry_id = "yatm_data_logic:data_arith_identity_vector",

    tiles = {
      "yatm_data_arith_top.identity.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.identity_vector(left, right, CONFIG)
      end,
    }),
  },

  add_vector = {
    description = "DATA Arithmetic [Addition Vector]\nAdds all input data",

    codex_entry_id = "yatm_data_logic:data_arith_add_vector",

    tiles = {
      "yatm_data_arith_top.add.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.add_vector(left, right, CONFIG)
      end,
    }),
  },

  subtract_vector = {
    description = "DATA Arithmetic [Subtraction Vector]\nSubtracts input data",

    codex_entry_id = "yatm_data_logic:data_arith_subtract_vector",

    tiles = {
      "yatm_data_arith_top.subtract.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.subtract_vector(left, right, CONFIG)
      end,
    }),
  },

  multiply_vector = {
    description = "DATA Arithmetic [Multiplication Vector]\nMultiply input data",

    codex_entry_id = "yatm_data_logic:data_arith_multiply_vector",

    tiles = {
      "yatm_data_arith_top.multiply.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.multiply_vector(left, right, CONFIG)
      end,
    }),
  },

  divide_vector = {
    description = "DATA Arithmetic [Division Vector]\nDivide input data",

    codex_entry_id = "yatm_data_logic:data_arith_divide_vector",

    tiles = {
      "yatm_data_arith_top.divide.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.divide_vector(left, right, CONFIG)
      end,
    }),
  },

  modulo_vector = {
    description = "DATA Arithmetic [Modulo Vector]\nModulo input data",

    codex_entry_id = "yatm_data_logic:data_arith_modulo_vector",

    tiles = {
      "yatm_data_arith_top.modulo.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.modulo_vector(left, right, CONFIG)
      end,
    }),
  },

  max_vector = {
    description = "DATA Arithmetic [Max Vector]\nPick largest input data",

    codex_entry_id = "yatm_data_logic:data_arith_max_vector",

    tiles = {
      "yatm_data_arith_top.max.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.max_vector(left, right, CONFIG)
      end,
    }),
  },

  min_vector = {
    description = "DATA Arithmetic [Min Vector]\nPick smallest input data",

    codex_entry_id = "yatm_data_logic:data_arith_min_vector",

    tiles = {
      "yatm_data_arith_top.min.vector.png",
      "yatm_data_arith_bottom.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
      "yatm_data_arith_side.png",
    },
    use_texture_alpha = "opaque",

    data_interface = table_merge(data_interface, {
      calculate = function (self, pos, node, left, right)
        return data_math.min_vector(left, right, CONFIG)
      end,
    }),
  },
})
