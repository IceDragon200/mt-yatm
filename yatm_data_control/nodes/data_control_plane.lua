local data_network = assert(yatm.data_network)

local function render_pads(inv, assigns)
  local formspec =
    "label[0.5,0.75;Pads]"

  local list = inv:get_list("pads")

  for y = 0,(assigns.height - 1) do
    local dy = 2 + y * 2
    for x = 0,(assigns.width - 1) do
      local dx = 2 + x * 2

      local i = 1 + y * assigns.width + x

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
                            ";pad_trigger_" .. i ..
                            ";" ..
                            ";true;false;" ..
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
  return formspec
end

local function get_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()

  assigns.width = 4
  assigns.height = 4

  local formspec =
    "formspec_version[2]" ..
    "size[12,12]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
    render_pads(inv, assigns)

  return formspec
end

local function get_formspec_name(pos)
  return "yatm_data_control:data_control_plane:" .. yatm.vector3.to_string(pos)
end

local function receive_fields(player, form_name, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  for pad_id = 1,16 do
    local pad_trigger = fields["pad_trigger_" .. pad_id]
    if pad_trigger then
      local port = meta:get_int("pad_port_" .. pad_id)
      local value = meta:get_string("pad_value_" .. pad_id)
      if port > 0 then
        yatm_data_logic.emit_value(assigns.pos, port, value)
      end
    end
  end
  return true
end

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
    assigns.width = 4
    assigns.height = 4

    local formspec =
      "formspec_version[2]" ..
      "size[12,12]" ..
      yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
      "tabheader[0,0;tab;Pads,Pads Setup,Ports,Data;" .. assigns.tab .. "]"

    if assigns.tab == 1 then
      formspec =
        formspec ..
        render_pads(inv, assigns)

    elseif assigns.tab == 2 then
      formspec =
        formspec ..
        "label[0.5,0.75;Pads Setup]" ..
        "list[nodemeta:" .. spos .. ";pads;4,1;4,4;]" ..
        "list[current_player;main;1,6.85;8,1;]" ..
        "list[current_player;main;1,8.08;8,3;8]" ..
        "listring[nodemeta:" .. spos .. ";pads]" ..
        "listring[current_player;main]" ..
        default.get_hotbar_bg(1, 6.85)

    elseif assigns.tab == 3 then
      formspec =
        formspec ..
        "label[0.5,0.75;Ports]"

      for y = 0,3 do
        local dy = 2 + y * 2
        for x = 0,3 do
          local dx = 2.125 + x * 2

          local i = 1 + y * 4 + x

          formspec =
            formspec ..
            "field[" .. dx .. "," .. dy ..
                   ";1.75,1" ..
                   ";pad_port_" .. i ..
                   ";Pad Port " .. i ..
                   ";" .. meta:get_int("pad_port_" .. i) .. "]"
        end
      end

    elseif assigns.tab == 4 then
      formspec =
        formspec ..
        "label[0.5,0.75;Data]"

      for y = 0,3 do
        local dy = 2 + y * 2
        for x = 0,3 do
          local dx = 2.125 + x * 2

          local i = 1 + y * 4 + x

          formspec =
            formspec ..
            "field[" .. dx .. "," .. dy ..
                   ";1.75,1" ..
                   ";pad_value_" .. i ..
                   ";Pad Value " .. i ..
                   ";" .. minetest.formspec_escape(meta:get_string("pad_value_" .. i)) .. "]"
        end
      end
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

    for pad_id = 1,16 do
      local new_pad_port = tonumber(fields["pad_port_" .. pad_id])
      if new_pad_port then
        meta:set_string("pad_port_" .. pad_id, new_pad_port)
      end

      local new_pad_value = fields["pad_value_" .. pad_id]
      if new_pad_value then
        meta:set_string("pad_value_" .. pad_id, new_pad_value)
      end

      local pad_trigger = fields["pad_trigger_" .. pad_id]
      if pad_trigger then
        local port = meta:get_int("pad_port_" .. pad_id)
        local value = meta:get_string("pad_value_" .. pad_id)
        if port > 0 then
          yatm_data_logic.emit_value(assigns.pos, port, value)
        end
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

  on_rightclick = function (pos, node, user, itemstack, pointed_thing)
    local assigns = { pos = pos, node = node }
    local formspec = get_formspec(pos, user, assigns)
    local formspec_name = get_formspec_name(pos)

    yatm_core.bind_on_player_receive_fields(user, formspec_name,
                                            assigns,
                                            receive_fields)

    minetest.show_formspec(
      user:get_player_name(),
      formspec_name,
      formspec
    )
  end,
})
