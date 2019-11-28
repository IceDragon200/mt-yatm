local data_network = assert(yatm.data_network)

local function mesecon_rules(node)
  local result = {}
  local i = 1
  for _, dir in ipairs(yatm_core.DIR4) do
    local new_dir = yatm_core.facedir_to_face(node.param2, dir)
    result[i] = yatm_core.DIR6_TO_VEC3[new_dir]
    i = i + 1
  end
  return result
end

yatm.register_stateful_node("yatm_data_to_mesecon:data_to_mesecon", {
  description = "Data To Mesecon",

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

  mesecons = {
    receptor = {
      state = mesecon.state.off,
      rules = mesecon_rules
    },
  },

  on_construct = function (pos)
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
    on_load = function (pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (pos, node, dir, port, value)
      if node.name == "yatm_data_to_mesecon:data_to_mesecon_off" then
        node.name = "yatm_data_to_mesecon:data_to_mesecon_on"
        minetest.swap_node(pos, node)
        yatm_data_logic.emit_output_data(pos, "on")
        mesecon.receptor_on(pos, mesecon_rules(node))
      elseif node.name == "yatm_data_to_mesecon:data_to_mesecon_on" then
        node.name = "yatm_data_to_mesecon:data_to_mesecon_off"
        minetest.swap_node(pos, node)
        yatm_data_logic.emit_output_data(pos, "off")
        mesecon.receptor_off(pos, mesecon_rules(node))
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

        local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "i")

        formspec =
          formspec ..
          io_formspec

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "label[0,1;Off (Data to trigger OFF state)]" ..
          "field[0.25,2;4,4;data_off;Data;" .. minetest.formspec_escape(meta:get_string("data_off")) .. "]" ..
          "label[4,1;On (Date to trigger ON state)]" ..
          "field[4.25,2;4,4;data_on;Data;" .. minetest.formspec_escape(meta:get_string("data_on")) .. "]"
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

      local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "i")

      if yatm_core.is_table_empty(inputs_changed) then
        yatm_data_logic.unmark_all_receive(assigns.pos)
        yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
      end

      if fields["data_off"] then
        meta:set_string("data_off", fields["data_off"])
      end

      if fields["data_on"] then
        meta:set_string("data_on", fields["data_on"])
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
}, {
  off = {
    tiles = {
      "yatm_data_mesecon_top.data.off.png",
      "yatm_data_mesecon_bottom.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
    },
  },
  on = {
    groups = {
      cracky = 1,
      data_programmable = 1,
      yatm_data_device = 1,
      not_in_creative_inventory = 1,
    },

    mesecons = {
      receptor = {
        state = mesecon.state.on,
        rules = mesecon_rules
      },
    },

    tiles = {
      "yatm_data_mesecon_top.data.on.png",
      "yatm_data_mesecon_bottom.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
    },
  }
})
