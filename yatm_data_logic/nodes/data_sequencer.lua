local data_network = assert(yatm.data_network)

minetest.register_node("yatm_data_logic:data_sequencer", {
  description = "Data Sequencer",

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
    },
  },

  tiles = {
    "yatm_data_sequencer_top.png",
    "yatm_data_sequencer_bottom.png",
    "yatm_data_sequencer_side.png",
    "yatm_data_sequencer_side.png",
    "yatm_data_sequencer_side.png",
    "yatm_data_sequencer_side.png",
  },

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (pos, node)
      -- toggles don't need to bind listeners of any sorts
    end,

    receive_pdu = function (pos, node, dir, port, value)
    end,

    get_programmer_formspec = function (self, pos, clicker, pointed_thing, assigns)
      --
      local meta = minetest.get_meta(pos)

      local formspec =
        "size[8,9]" ..
        "label[0,0;Port Configuration]" ..
        yatm_data_logic.get_io_port_formspec(pos, meta, "o")

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

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      if yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
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
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
