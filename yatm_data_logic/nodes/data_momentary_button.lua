local data_network = assert(yatm.data_network)

yatm.register_stateful_node("yatm_data_logic:data_momentary_button", {
  description = "Data Momentary Button",

  codex_entry_id = "yatm_data_logic:data_momentary_button",

  drop = "yatm_data_logic:data_momentary_button_off",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

  drawtype = "nodebox",

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      -- toggles don't need to bind listeners of any sorts
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      --
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

        local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "o")

        formspec =
          formspec ..
          io_formspec

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "label[0,1;On Trigger]" ..
          "field[0.25,2;4,1;data_trigger;Data;" .. minetest.formspec_escape(meta:get_string("data_trigger")) .. "]" ..
          "label[4,1;On Release]" ..
          "field[4.25,2;4,1;data_release;Data;" .. minetest.formspec_escape(meta:get_string("data_release")) .. "]"
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

      yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

      if fields["data_trigger"] then
        meta:set_string("data_trigger", fields["data_trigger"])
      end

      if fields["data_release"] then
        meta:set_string("data_release", fields["data_release"])
      end

      if needs_refresh then
        local formspec = self:get_programmer_formspec(assigns.pos, player, nil, assigns)
        return true, formspec
      else
        return true
      end
    end,
  },

  on_timer = function (pos)
    local node = minetest.get_node(pos)

    if node.name == "yatm_data_logic:data_momentary_button_on" then
      node.name = "yatm_data_logic:data_momentary_button_off"

      minetest.swap_node(pos, node)

      yatm_data_logic.emit_output_data(pos, "release")
    end

    return false
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,
}, {
  off = {
    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(), -- base
        yatm_core.Cuboid:new(3, 4, 3, 10, 1, 10):fast_node_box(), -- button
      },
    },

    tiles = {
      "yatm_data_momentary_button_top.off.png",
      "yatm_data_momentary_button_bottom.png",
      "yatm_data_momentary_button_side.off.png",
      "yatm_data_momentary_button_side.off.png",
      "yatm_data_momentary_button_side.off.png",
      "yatm_data_momentary_button_side.off.png",
    },

    on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
      node.name = "yatm_data_logic:data_momentary_button_on"
      minetest.swap_node(pos, node)

      minetest.get_node_timer(pos):start(0.25)

      yatm_data_logic.emit_output_data(pos, "trigger")
    end,
  },

  on = {
    groups = {
      cracky = 1,
      data_programmable = 1,
      yatm_data_device = 1,
      not_in_creative_inventory = 1,
    },

    node_box = {
      type = "fixed",
      fixed = {
        yatm_core.Cuboid:new(0, 0, 0, 16, 4, 16):fast_node_box(),
      },
    },

    tiles = {
      "yatm_data_momentary_button_top.on.png",
      "yatm_data_momentary_button_bottom.png",
      "yatm_data_momentary_button_side.on.png",
      "yatm_data_momentary_button_side.on.png",
      "yatm_data_momentary_button_side.on.png",
      "yatm_data_momentary_button_side.on.png",
    },

    on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
    end,
  },
})
