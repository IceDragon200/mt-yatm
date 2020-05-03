local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)

local function refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Console Monitor\n" ..
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. " [" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "]\n" ..
    data_network:get_infotext(pos) .. "\n" ..
    ""

  meta:set_string("infotext", infotext)
end

local data_interface = {
  on_load = function (self, pos, node)
    yatm_data_logic.mark_all_inputs_for_active_receive(pos)
  end,

  receive_pdu = function (self, pos, node, dir, port, value)
    local meta = minetest.get_meta(pos)

    local str = yatm_core.string_hex_unescape(value)
  end,

  get_programmer_formspec = function (self, pos, user, pointed_thing, assigns)
    --
    local meta = minetest.get_meta(pos)

    local formspec =
      "size[8,9]" ..
      yatm.formspec_bg_for_player(user:get_player_name(), "display") ..
      "label[0,0;Port Configuration]" ..
      yatm_data_logic.get_io_port_formspec(pos, meta, "io")

    return formspec
  end,

  receive_programmer_fields = function (self, player, form_name, fields, assigns)
    local meta = minetest.get_meta(assigns.pos)

    local inputs_changed = yatm_data_logic.handle_io_port_fields(assigns.pos, fields, meta, "io")

    if not yatm_core.is_table_empty(inputs_changed) then
      yatm_data_logic.unmark_all_receive(assigns.pos)
      yatm_data_logic.mark_all_inputs_for_active_receive(assigns.pos)
    end

    return true
  end,
}

local function get_formspec(pos, user, assigns)
  local meta = minetest.get_meta(pos)

  local formspec =
    "formspec_version[2]" ..
    "size[12,12]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "display") ..
    "textarea[0.5,1;11,9;;History;" .. minetest.formspec_escape(meta:get_string("history")) .. "]" ..
    "field[0.5,10.5;11,1;console_input;;]" ..
    "field_close_on_enter[console_input;false]" ..
    ""

  return formspec
end

local function get_formspec_name(pos)
  return "yatm_data_console_monitor:console_monitor:" .. yatm.vector3.to_string(pos)
end

local function append_history(meta, new_line)
  local history = meta:get_string("history")
  local lines = yatm_core.string_split(history, "\n")
  table.insert(lines, new_line)
  lines = yatm_core.list_last(lines, 16)
  meta:set_string("history", table.concat(lines, "\n"))
end

local function receive_fields(player, form_name, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)
  local needs_refresh = false

  --
  if fields["key_enter_field"] then
    if fields["key_enter_field"] == "console_input" then
      local new_line = fields.console_input
      append_history(meta, new_line)

      minetest.log("action", player:get_player_name() .. " sent some data from console")
      yatm_data_logic.emit_output_data_value(assigns.pos, new_line)
      needs_refresh = true
    end
  end

  if needs_refresh then
    return true, get_formspec(assigns.pos, player, assigns)
  else
    return true
  end
end

local function on_rightclick(pos, node, user, itemstack, pointed_thing)
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
end

local flat_monitor_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, 0.25, 0.5, 0.5, 0.5}, -- NodeBox1
  }
}

local monitor_groups = {
  cracky = 1,
  monitor = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
  data_programmable = 1,
  yatm_data_device = 1,
}

local monitor_console_yatm_network = {
  basename = "yatm_data_console_monitor:monitor_console",
  kind = "monitor",
  groups = {
    monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_data_console_monitor:monitor_console_error",
    conflict = "yatm_data_console_monitor:monitor_console_error",
    off = "yatm_data_console_monitor:monitor_console_off",
    on = "yatm_data_console_monitor:monitor_console_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
  },
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = "yatm_data_console_monitor:monitor_console",

  basename = "yatm_data_console_monitor:monitor_console",

  description = "Monitor (console)",

  groups = monitor_groups,

  drop = monitor_console_yatm_network.states.off,

  tiles = {
    "yatm_console_monitor_top.png",
    "yatm_console_monitor_bottom.data.png",
    "yatm_console_monitor_side.png",
    "yatm_console_monitor_side.png^[transformFX",
    "yatm_console_monitor_back.data.png",
    "yatm_console_monitor_front.console.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = monitor_console_yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = function (pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("history", "")
    local node = minetest.get_node(pos)
    yatm.devices.device_on_construct(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    yatm.devices.device_after_destruct(pos, node)
    data_network:remove_node(pos, node)
  end,

  on_rightclick = on_rightclick,

  data_network_device = {
    type = "device",
  },
  data_interface = data_interface,
}, {
  error = {
    tiles = {
      "yatm_console_monitor_top.png",
      "yatm_console_monitor_bottom.data.png",
      "yatm_console_monitor_side.png",
      "yatm_console_monitor_side.png^[transformFX",
      "yatm_console_monitor_back.data.png",
      "yatm_console_monitor_front.console.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_console_monitor_top.png",
      "yatm_console_monitor_bottom.data.png",
      "yatm_console_monitor_side.png",
      "yatm_console_monitor_side.png^[transformFX",
      "yatm_console_monitor_back.data.png",
      {
        name = "yatm_console_monitor_front.console.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
    },
  },
})

local flat_monitor_console_yatm_network = {
  kind = "monitor",
  groups = {
    monitor = 1,
    console_monitor = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    error = "yatm_data_console_monitor:flat_monitor_console_error",
    conflict = "yatm_data_console_monitor:flat_monitor_console_error",
    off = "yatm_data_console_monitor:flat_monitor_console_off",
    on = "yatm_data_console_monitor:flat_monitor_console_on",
  },
  energy = {
    capacity = 4000,
    network_charge_bandwidth = 100,
    passive_lost = 10,
  },
}

local flat_monitor_groups = {
  cracky = 1,
  monitor = 1,
  yatm_energy_device = 1,
  yatm_network_device = 1,
  data_programmable = 1,
  yatm_data_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_data_console_monitor:flat_monitor_console",

  description = "Flat Monitor (console)",
  groups = flat_monitor_groups,

  drop = flat_monitor_console_yatm_network.states.off,

  tiles = {
    "yatm_console_monitor_top.flat.png",
    "yatm_console_monitor_bottom.data.flat.png",
    "yatm_console_monitor_side.flat.png",
    "yatm_console_monitor_side.flat.png^[transformFX",
    "yatm_console_monitor_back.data.png",
    "yatm_console_monitor_front.console.off.png",
  },
  drawtype = "nodebox",
  node_box = flat_monitor_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = flat_monitor_console_yatm_network,

  refresh_infotext = refresh_infotext,

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    yatm.devices.device_on_construct(pos)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    yatm.devices.device_after_destruct(pos, node)
    data_network:remove_node(pos, node)
  end,

  on_rightclick = on_rightclick,

  data_network_device = {
    type = "device",
  },
  data_interface = data_interface,
}, {
  error = {
    tiles = {
      "yatm_console_monitor_top.flat.png",
      "yatm_console_monitor_bottom.data.flat.png",
      "yatm_console_monitor_side.flat.png",
      "yatm_console_monitor_side.flat.png^[transformFX",
      "yatm_console_monitor_back.data.png",
      "yatm_console_monitor_front.console.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_console_monitor_top.flat.png",
      "yatm_console_monitor_bottom.data.flat.png",
      "yatm_console_monitor_side.flat.png",
      "yatm_console_monitor_side.flat.png^[transformFX",
      "yatm_console_monitor_back.data.png",
      {
        name = "yatm_console_monitor_front.console.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
    },
  }
})
