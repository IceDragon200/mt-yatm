local Vector3 = assert(foundation.com.Vector3)
local Cuboid = assert(foundation.com.Cuboid)
local ng = Cuboid.new_fast_node_box
local fspec = assert(foundation.com.formspec.api)

local data_network = assert(yatm.data_network)

local function render_pads(inv, meta, assigns)
  local formspec =
    fpsec.label(0.5, 0.75, "Pads")

  local list = inv:get_list("pads")

  local bw = assigns.scale
  local bh = assigns.scale

  local bd = ";" .. bw .. "," .. bh

  local xoffset = (12 - assigns.width * assigns.scale) / 2
  local yoffset = (12 - assigns.height * assigns.scale) / 2

  for y = 0,(assigns.height - 1) do
    local dy = yoffset + y * assigns.scale
    for x = 0,(assigns.width - 1) do
      local dx = xoffset + x * assigns.scale

      local i = 1 + y * assigns.width + x

      if not list[i]:is_empty() then
        local stack = list[i]
        local spec = stack:get_definition().data_control_spec
        if spec then
          if spec.type == "momentary_button" then
            -- momentary button
            formspec =
              formspec ..
              "image_button[" .. dx .. "," .. dy ..
                            bd .. ";" ..
                            minetest.formspec_escape("yatm_button.base.48px.png^" .. spec.images["off"]) ..
                            ";pad_trigger_" .. i ..
                            ";" ..
                            ";true;false;" ..
                            minetest.formspec_escape("yatm_button.base.48px.png^" .. spec.images["on"]) .. "]"
          elseif spec.type == "switch2" then
            -- 2 state switch
            local state_id = meta:get_int("pad_state_" .. i)
            local state = "left"
            if state_id ~= 0 then
              state = "right"
            end

            formspec =
              formspec ..
              "image_button[" .. dx .. "," .. dy ..
                            bd .. ";" ..
                            minetest.formspec_escape("yatm_button.base.48px.png^yatm_button.base.switch.48px.png^" .. spec.images[state]) ..
                            ";pad_toggle_" .. i ..
                            ";" ..
                            ";true;false;" ..
                            minetest.formspec_escape("yatm_button.base.48px.png^yatm_button.base.switch.48px.png^" .. spec.images[state]) .. "]"
          else
            formspec =
              formspec ..
              "image[" .. dx .. "," .. dy .. bd .. ";yatm_button.base.handles.48px.png]"
          end
        else
          formspec =
            formspec ..
            "image[" .. dx .. "," .. dy .. bd .. ";yatm_button.base.48px.png]"
        end
      else
        formspec =
          formspec ..
          "image[" .. dx .. "," .. dy .. bd .. ";yatm_button.base.handles.48px.png]"
      end
    end
  end
  return formspec
end

local function get_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)
  local node = minetest.get_node(pos)
  local nodedef = minetest.registered_nodes[node.name]
  local inv = meta:get_inventory()

  assigns.scale = 2.5

  assigns.width = nodedef.control_panel.width
  assigns.height = nodedef.control_panel.height
  assigns.size = assigns.width * assigns.height
  assigns.scale = 10 / assigns.width

  local formspec =
    yatm_data_logic.layout_formspec() ..
    yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
    render_pads(inv, meta, assigns)

  return formspec
end

local function get_formspec_name(pos)
  return "yatm_data_control:data_control_plane:" .. Vector3.to_string(pos)
end

local function check_pad_trigger(pad_id, meta, fields, assigns)
  local needs_refresh = false
  local pad_trigger = fields["pad_trigger_" .. pad_id]
  if pad_trigger then
    local port = meta:get_int("pad_port_" .. pad_id)
    local value = meta:get_string("pad_state_value_" .. pad_id .. "_1")
    if port > 0 then
      yatm_data_logic.emit_value(assigns.pos, port, value)
    end
  end

  local pad_toggle = fields["pad_toggle_" .. pad_id]
  if pad_toggle then
    local state = meta:get_int("pad_state_" .. pad_id)
    if state == 0 then
      state = 1
    else
      state = 0
    end
    meta:set_int("pad_state_" .. pad_id, state)
    needs_refresh = true

    local port = meta:get_int("pad_port_" .. pad_id)
    local value = meta:get_string("pad_state_value_" .. pad_id .. "_" .. state)
    if port > 0 then
      yatm_data_logic.emit_value(assigns.pos, port, value)
    end
  end

  return needs_refresh
end

local function receive_fields(player, form_name, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  local needs_refresh = false

  for pad_id = 1,assigns.size do
    if check_pad_trigger(pad_id, meta, fields, assigns) then
      needs_refresh = true
    end
  end

  if needs_refresh then
    return true, get_formspec(assigns.pos, player, assigns)
  else
    return true
  end
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
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    assigns.tab = assigns.tab or 1
    assigns.width = nodedef.control_panel.width
    assigns.height = nodedef.control_panel.height
    assigns.size = assigns.width * assigns.height
    assigns.scale = 10 / assigns.width

    local xoffset = (12 - assigns.width * assigns.scale) / 2
    local yoffset = (12 - assigns.height * assigns.scale) / 2

    local formspec =
      "formspec_version[2]" ..
      "size[12,12]" ..
      yatm.formspec_bg_for_player(user:get_player_name(), "module") ..
      "tabheader[0,0;tab;Pads,Pads Setup,Ports,Data;" .. assigns.tab .. "]"

    if assigns.tab == 1 then
      formspec =
        formspec ..
        render_pads(inv, meta, assigns)

    elseif assigns.tab == 2 then
      formspec =
        formspec ..
        "label[0.5,0.75;Pads Setup]" ..
        "list[nodemeta:" .. spos .. ";pads;0.5,1;" .. assigns.width .. "," .. assigns.height .. ";]" ..
        "list[current_player;main;1,6.85;8,1;]" ..
        "list[current_player;main;1,8.08;8,3;8]" ..
        "listring[nodemeta:" .. spos .. ";pads]" ..
        "listring[current_player;main]"

    elseif assigns.tab == 3 then
      formspec =
        formspec ..
        "label[0.5,0.75;Ports]"

      for y = 0,(assigns.height - 1) do
        local dy = yoffset + 0.5 + y * assigns.scale
        for x = 0,(assigns.width - 1) do
          local dx = xoffset + x * assigns.scale

          local i = 1 + y * assigns.width + x

          formspec =
            formspec ..
            "field[" .. dx .. "," .. dy ..
                   ";" .. assigns.scale .. ",0.8" ..
                   ";pad_port_" .. i ..
                   ";P" .. i ..
                   ";" .. meta:get_int("pad_port_" .. i) .. "]"
        end
      end

    elseif assigns.tab == 4 then
      formspec =
        formspec ..
        "label[0.5,0.75;Data]"

      for y = 0,(assigns.height - 1) do
        local dy = yoffset + 0.5 + y * assigns.scale
        for x = 0,(assigns.width - 1) do
          local dx = xoffset + x * assigns.scale

          local i = 1 + y * assigns.width + x

          local stack = inv:get_stack("pads", i)

          if stack:is_empty() then
            --
          else
            local def = stack:get_definition()

            if def.data_control_spec then
              local spec = def.data_control_spec
              if spec.type == "momentary_button" then
                formspec =
                  formspec ..
                  "field[" .. dx .. "," .. dy ..
                         ";2.5,1" ..
                         ";pad_state_value_" .. i .. "_1" ..
                         ";T" .. i ..
                         ";" .. minetest.formspec_escape(meta:get_string("pad_state_value_" .. i .. "_1")) .. "]"
              elseif spec.type == "switch2" then
                formspec =
                  formspec ..
                  "field[" .. dx .. "," .. dy ..
                         ";1.125,1" ..
                         ";pad_state_value_" .. i .. "_0" ..
                         ";L" .. i ..
                         ";" .. minetest.formspec_escape(meta:get_string("pad_state_value_" .. i .. "_0")) .. "]" ..
                  "field[" .. (1.25 + dx) .. "," .. dy ..
                         ";1.125,1" ..
                         ";pad_state_value_" .. i .. "_1" ..
                         ";R" .. i ..
                         ";" .. minetest.formspec_escape(meta:get_string("pad_state_value_" .. i .. "_1")) .. "]"
              end
            end
          end
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

    for pad_id = 1,assigns.size do
      local new_pad_port = tonumber(fields["pad_port_" .. pad_id])
      if new_pad_port then
        meta:set_string("pad_port_" .. pad_id, new_pad_port)
      end

      for state_id = 0,1 do
        local field_name = "pad_state_value_" .. pad_id .. "_" .. state_id
        local new_pad_value = fields[field_name]
        if new_pad_value then
          meta:set_string(field_name, new_pad_value)
        end
      end

      if check_pad_trigger(pad_id, meta, fields, assigns) then
        needs_refresh = true
      end
    end

    return true, needs_refresh
  end,
}

yatm.register_stateful_node("yatm_data_control:data_control_plane", {
  codex_entry_id = "yatm_data_control:data_control_plane",

  base_description = "Data Control Plane",

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
      ng(0, 0, 0, 16, 4, 16),
      ng(3, 4, 3, 10, 1, 10),
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
    local node = minetest.get_node(pos)
    local nodedef = minetest.registered_nodes[node.name]
    inv:set_size("pads", nodedef.control_panel.width * nodedef.control_panel.height)
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
      "Control Panel\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,

  on_rightclick = function (pos, node, user, itemstack, pointed_thing)
    local assigns = { pos = pos, node = node }
    local formspec = get_formspec(pos, user, assigns)
    local formspec_name = get_formspec_name(pos)

    yatm_core.show_bound_formspec(user:get_player_name(), formspec_name, formspec, {
      state = assigns,
      on_receive_fields = receive_fields
    })
  end,
}, {
  ["2x2"] = {
    description = "Data Control Plane [2x2]",

    control_panel = {
      width = 2,
      height = 2,
    },
  },

  ["4x4"] = {
    description = "Data Control Plane [4x4]",

    control_panel = {
      width = 4,
      height = 4,
    },
  },

  ["8x8"] = {
    description = "Data Control Plane [8x8]",

    control_panel = {
      width = 8,
      height = 8,
    },
  },
})
