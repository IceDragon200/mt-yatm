--
-- Comparator Data Hubs
--
-- Comparator's take data input and then compare them before emitting a different payload depending on whether it was true or false.
local data_network = assert(yatm.data_network)

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    print(minetest.pos_to_string(pos), node.name,
          yatm_core.DIR_TO_STRING[dir], port,
          dump(value))

    local meta = minetest.get_meta(pos)
    local sub_network_ids = data_network:get_sub_network_ids(pos)
    local input_port = meta:get_int("input_" .. dir)
    if input_port > 0 then
      meta:set_string("input_value_" .. dir, value)

      local ops = meta:get_string("operands")
      local operands = {}
      for i = 1,#ops do
        operands[i] = string.sub(ops, i, i)
      end

      -- requires at least 2 values
      if operands[1] and operands[2] then
        local left_dir = yatm_core.STRING1_TO_DIR[operands[1]]
        local right_dir = yatm_core.STRING1_TO_DIR[operands[2]]

        if left_dir and right_dir then
          local left = yatm_core.string_hex_unescape(meta:get_string("input_value_" .. left_dir))
          local right = yatm_core.string_hex_unescape(meta:get_string("input_value_" .. right_dir))

          print(minetest.pos_to_string(pos), node.name,
                yatm_core.DIR_TO_STRING1[left_dir], dump(left),
                yatm_core.DIR_TO_STRING1[right_dir], dump(right))

          local name
          if self:operate(pos, node, left, right) then
            name = "true"
          else
            name = "false"
          end

          yatm_data_logic.emit_output_data(pos, name)

          if meta:get_string("last_result") ~= name then
            meta:set_string("last_result", name)
            yatm.queue_refresh_infotext(pos, node)
          end
        else
          print(minetest.pos_to_string(pos), node.name, "no valid directions")
        end
      else
        print(minetest.pos_to_string(pos), node.name, "operands are invalid")
      end
    end
  end,

  get_programmer_formspec = function (self, pos, clicker, pointed_thing, assigns)
    --
    local meta = minetest.get_meta(pos)

    assigns.tab = assigns.tab or 1

    local formspec =
      "size[8,9]" ..
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
        "field[0.25,2;8,1;operands;Operands;" .. minetest.formspec_escape(meta:get_string("operands")) .. "]" ..
        "label[0,3;Truthy]" ..
        "field[0.25,4;4,1;data_true;Data;" .. minetest.formspec_escape(meta:get_string("data_true")) .. "]" ..
        "label[4,3;Falsy]" ..
        "field[4.25,4;4,1;data_false;Data;" .. minetest.formspec_escape(meta:get_string("data_false")) .. "]"
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

    if fields["data_true"] then
      meta:set_string("data_true", fields["data_true"])
    end

    if fields["data_false"] then
      meta:set_string("data_false", fields["data_false"])
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
      meta:set_string("operands", string.sub(result, 1, 2))
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

yatm.register_stateful_node("yatm_data_logic:data_comparator", {
  base_description = "Data Comparator",

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

    meta:set_string("operands", "")
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
      "Last Result: " .. meta:get_string("last_result") .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
}, {
  --
  -- Normal Mode
  --
  equal_to = {
    description = "Data Comparator [Equal To]",

    tiles = {
      "yatm_data_comparator_top.equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, left, right)
        return left == right
      end,
    }),
  },

  not_equal_to = {
    description = "Data Comparator [Not Equal To]",

    tiles = {
      "yatm_data_comparator_top.not_equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, left, right)
        return left ~= right
      end,
    }),
  },

  greater_than = {
    description = "Data Comparator [Greater Than]",

    tiles = {
      "yatm_data_comparator_top.greater_than.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, left, right)
        return left > right
      end,
    }),
  },

  greater_than_or_equal_to = {
    description = "Data Comparator [Greater Than or Equal To]",

    tiles = {
      "yatm_data_comparator_top.greater_than_or_equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, left, right)
        return left >= right
      end,
    }),
  },

  less_than = {
    description = "Data Comparator [Less Than]",

    tiles = {
      "yatm_data_comparator_top.less_than.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, left, right)
        return left < right
      end,
    }),
  },

  less_than_or_equal_to = {
    description = "Data Comparator [Less Than or Equal To]",

    tiles = {
      "yatm_data_comparator_top.less_than_or_equal_to.png",
      "yatm_data_comparator_bottom.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
      "yatm_data_comparator_side.png",
    },

    data_interface = yatm_core.table_merge(data_interface, {
      operate = function (self, pos, node, left, right)
        return left <= right
      end,
    }),
  },
})
