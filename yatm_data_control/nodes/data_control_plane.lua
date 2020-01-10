local data_network = assert(yatm.data_network)

local data_interface = {
  on_load = function (self, pos, node)
    --
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    --
  end,

  get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
    --
    local spos = pos.x .. "," .. pos.y .. "," .. pos.z
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    assigns.tab = assigns.tab or 1

    local formspec =
      "formspec_version[2]" ..
      "size[10,12]" ..
      yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
      "tabheader[0,0;tab;Pads,Pads Setup,Ports,Data;" .. assigns.tab .. "]"

    if assigns.tab == 1 then
      formspec =
        formspec ..
        "label[0.5,0.5;Pads]"

      local list = inv:get_list("pads")

      for y = 0,3 do
        local dy = 1 + y * 2
        for x = 0,3 do
          local dx = 1 + x * 2
          local i = 1 + y * 4 + x

          if not list[i]:is_empty() then
            local stack = list[i]
            local spec = stack:get_definition().data_control_spec
            if spec then
              if spec.type == "momentary_button" then
                formspec =
                  formspec ..
                  "image_button[" .. dx .. "," .. dy ..
                                ";2,2;" ..
                                minetest.formspec_escape("yatm_button.base.48px.png^" .. spec.images["off"]) ..
                                ";pad" .. i ..
                                ";;true;false;" ..
                                minetest.formspec_escape("yatm_button.base.48px.png^" ..spec.images["on"]) .. "]"
              end
            else
              formspec =
                formspec ..
                "image[" .. dx .. "," .. dy .. ";2,2;yatm_button.base.48px.png]"
            end
          else
            formspec =
              formspec ..
              "image[" .. dx .. "," .. dy .. ";2,2;yatm_button.base.48px.png]"
          end
        end
      end
    elseif assigns.tab == 2 then
      formspec =
        formspec ..
        "label[0.5,0.5;Pads Setup]" ..
        "list[nodemeta:" .. spos .. ";pads;0.5,1;4,4;]" ..
        "list[current_player;main;0.5,5.85;8,1;]" ..
        "list[current_player;main;0.5,7.08;8,3;8]" ..
        "listring[nodemeta:" .. spos .. ";pads]" ..
        "listring[current_player;main]" ..
        default.get_hotbar_bg(0.5, 5.85)

    elseif assigns.tab == 3 then
      formspec =
        formspec ..
        "label[1,0.5;Ports]"

    elseif assigns.tab == 4 then
      formspec =
        formspec ..
        "label[1,0.5;Data]"
    end

    return formspec
  end,

  receive_programmer_fields = function (self, player, form_name, fields, assigns)
    local meta = minetest.get_meta(assigns.pos)

    local needs_refresh = false

    print(dump(fields))

    if fields["tab"] then
      local tab = tonumber(fields["tab"])
      if tab ~= assigns.tab then
        assigns.tab = tab
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

minetest.register_node("yatm_data_control:data_control_plane", {
  description = "Data Control Plane [4x4]",

  codex_entry_id = "yatm_data_control:data_control_plane",

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

  tiles = {
    "yatm_data_control_plane_top.png",
    "yatm_data_control_plane_bottom.png",
    "yatm_data_control_plane_side.png",
    "yatm_data_control_plane_side.png",
    "yatm_data_control_plane_side.png",
    "yatm_data_control_plane_side.png",
  },

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    inv:set_size("pads", 16)
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
    local infotext =
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,
})
