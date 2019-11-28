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

yatm.register_stateful_node("yatm_data_to_mesecon:mesecon_to_data", {
  description = "Mesecon To Data",

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
      --
    end,

    receive_pdu = function (pos, node, dir, port, value)
      --
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

        local io_formspec = yatm_data_logic.get_io_port_formspec(pos, meta, "o")

        formspec =
          formspec ..
          io_formspec

      elseif assigns.tab == 2 then
        formspec =
          formspec ..
          "label[0,0;Data Configuration]" ..
          "label[0,1;Off (When triggered OFF)]" ..
          "field[0.25,2;4,4;data_off;Data;" .. minetest.formspec_escape(meta:get_string("data_off")) .. "]" ..
          "label[4,1;On (When triggered ON)]" ..
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

      yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "o")

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
    mesecons = {
      effector = {
        rules = mesecon_rules,

        action_on = function (pos, node)
          node.name = "yatm_data_to_mesecon:mesecon_to_data_on"
          minetest.swap_node(pos, node)
          yatm_data_logic.emit_output_data(pos, "on")
        end,
      },
    },

    tiles = {
      "yatm_data_mesecon_top.mesecon.off.png",
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
      effector = {
        rules = mesecon_rules,

        action_off = function (pos, node)
          node.name = "yatm_data_to_mesecon:mesecon_to_data_off"
          minetest.swap_node(pos, node)
          yatm_data_logic.emit_output_data(pos, "off")
        end,
      },
    },

    tiles = {
      "yatm_data_mesecon_top.mesecon.on.png",
      "yatm_data_mesecon_bottom.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
      "yatm_data_mesecon_side.png",
    },
  }
})
