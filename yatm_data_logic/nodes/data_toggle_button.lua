local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local sounds = assert(yatm_core.sounds)
local data_network = assert(yatm.data_network)

yatm.register_stateful_node("yatm_data_logic:data_toggle_button", {
  description = "Data Toggle Button",

  codex_entry_id = "yatm_data_logic:data_toggle_button",

  groups = {
    cracky = 1,
    data_programmable = 1,
    yatm_data_device = 1,
  },

  paramtype = "light",
  paramtype2 = "facedir",

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
        yatm_data_logic.layout_formspec() ..
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
          "label[0,1;Left (0)]" ..
          "field[0.25,2;4,1;data_left;Data;" .. minetest.formspec_escape(meta:get_string("data_left")) .. "]" ..
          "label[4,1;Right (1)]" ..
          "field[4.25,2;4,1;data_right;Data;" .. minetest.formspec_escape(meta:get_string("data_right")) .. "]"
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

      if fields["data_left"] then
        meta:set_string("data_left", fields["data_left"])
      end

      if fields["data_right"] then
        meta:set_string("data_right", fields["data_right"])
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

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    data_network:remove_node(pos, node)
  end,
}, {
  left = {
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 4, 16),
        ng(2, 4, 3,  6, 2, 10),
      },
    },

    tiles = {
      "yatm_data_toggle_button_top.left.png",
      "yatm_data_toggle_button_bottom.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_front.left.png^[transformFX",
      "yatm_data_toggle_button_front.left.png",
    },

    on_rightclick = function (pos, node, clicker)
      sounds:play("button_click", { pos = pos, max_hear_distance = 32 })
      node.name = "yatm_data_logic:data_toggle_button_right"
      minetest.swap_node(pos, node)

      yatm_data_logic.emit_output_data(pos, "left")
    end,
  },

  right = {
    drawtype = "nodebox",
    node_box = {
      type = "fixed",
      fixed = {
        ng(0, 0, 0, 16, 4, 16),
        ng(8, 4, 3,  6, 2, 10),
      },
    },

    tiles = {
      "yatm_data_toggle_button_top.right.png",
      "yatm_data_toggle_button_bottom.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_side.png",
      "yatm_data_toggle_button_front.right.png^[transformFX",
      "yatm_data_toggle_button_front.right.png",
    },

    on_rightclick = function (pos, node, clicker)
      sounds:play("button_click", { pos = pos, max_hear_distance = 32 })
      node.name = "yatm_data_logic:data_toggle_button_left"
      minetest.swap_node(pos, node)

      yatm_data_logic.emit_output_data(pos, "right")
    end,
  },
})
