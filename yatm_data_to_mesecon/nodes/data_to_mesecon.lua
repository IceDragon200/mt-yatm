local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local Directions = assert(foundation.com.Directions)
local is_table_empty = assert(foundation.com.is_table_empty)
local string_hex_unescape = assert(foundation.com.string_hex_unescape)
local data_network = assert(yatm.data_network)

local function mesecon_rules(node)
  local result = {}
  local i = 1
  for _, dir in ipairs(Directions.DIR4) do
    local new_dir = Directions.facedir_to_face(node.param2, dir)
    result[i] = Directions.DIR6_TO_VEC3[new_dir]
    i = i + 1
  end
  return result
end

yatm.register_stateful_node("yatm_data_to_mesecon:data_to_mesecon", {
  --description = "Data To Mesecon",
  description = "Data Switcher",

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
      ng(3, 4, 3, 10, 2, 10),
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
    on_load = function (self, pos, node)
      yatm_data_logic.mark_all_inputs_for_active_receive(pos)
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      local meta = minetest.get_meta(pos)
      local new_value = string_hex_unescape(value)

      if node.name == "yatm_data_to_mesecon:data_to_mesecon_off" then
        if string_hex_unescape(meta:get_string("data_on")) == new_value then
          node.name = "yatm_data_to_mesecon:data_to_mesecon_on"
          minetest.swap_node(pos, node)
          mesecon.receptor_on(pos, mesecon_rules(node))
        end
      elseif node.name == "yatm_data_to_mesecon:data_to_mesecon_on" then
        if string_hex_unescape(meta:get_string("data_off")) == new_value then
          node.name = "yatm_data_to_mesecon:data_to_mesecon_off"
          minetest.swap_node(pos, node)
          mesecon.receptor_off(pos, mesecon_rules(node))
        end
      end
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

        local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "i")

        formspec =
          formspec ..
          io_formspec

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "label[4,1;On (Data to trigger ON state)]" ..
          "field[4.25,2;4,4;data_on;Data;" .. minetest.formspec_escape(meta:get_string("data_on")) .. "]" ..
          "label[0,1;Off (Data to trigger OFF state)]" ..
          "field[0.25,2;4,4;data_off;Data;" .. minetest.formspec_escape(meta:get_string("data_off")) .. "]" ..
          ""
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

      if not is_table_empty(inputs_changed) then
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
