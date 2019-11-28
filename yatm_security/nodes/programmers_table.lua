if not yatm_machines then
  return
end

--
-- A programmers table is the node equivalent of the programming tool.
-- However its main purpose is to program items, not other nodes.
-- So it's not really an equivalent, it has a totally different function...
--
local data_network = assert(yatm.data_network)
local cluster_energy = assert(yatm.cluster.energy)
local cluster_devices = assert(yatm.cluster.devices)
local Energy = assert(yatm.energy)

local function get_formspec(pos, assigns)
  local meta = minetest.get_meta(pos)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z

  local formspec =
    "size[12,10]" ..
    "label[0,0;Programmer's Table]" ..
    "field[0,1;8,1;prog_data;Program Data;" .. minetest.formspec_escape(meta:get_string("prog_data")) .. "]" ..
    "list[nodemeta:" .. spos .. ";input_items;0,2;4,4;]" ..
    "list[nodemeta:" .. spos .. ";processing_items;4,2;4,4;]" ..
    "list[nodemeta:" .. spos .. ";output_items;8,2;4,4;]" ..
    "list[current_player;main;2,4.85;8,1;]" ..
    "list[current_player;main;2,6.08;8,3;8]" ..
    "listring[nodemeta:" .. spos .. ";input_items]" ..
    "listring[current_player;main]" ..
    "listring[nodemeta:" .. spos .. ";output_items]" ..
    "listring[current_player;main]" ..
    default.get_hotbar_bg(2,4.85)

  return formspec
end

local function handle_receive_fields(player, formname, fields, assigns)
  local meta = minetest.get_meta(assigns.pos)

  if fields["prog_data"] then
    meta:set_string("prog_data", fields["prog_data"])
  end

  return true
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_security:programmers_table",

  description = "Programmer's Table",

  drop = "yatm_security:programmers_table_off",

  groups = {
    cracky = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
    yatm_data_device = 1,
  },

  tiles = {
    "yatm_programmers_table_top.off.png",
    "yatm_programmers_table_bottom.off.png",
    "yatm_programmers_table_side.off.png",
    "yatm_programmers_table_side.off.png",
    "yatm_programmers_table_side.off.png",
    "yatm_programmers_table_side.off.png",
  },

  yatm_network = {
    kind = "machine",

    groups = {
      machine_worker = 1,
      energy_consumer = 1,
    },

    default_state = "off",
    states = {
      off = "yatm_security:programmers_table_off",
      on = "yatm_security:programmers_table_on",
      error = "yatm_security:programmers_table_error",
      conflict = "yatm_security:programmers_table_error",
    },

    energy = {
      capacity = 16000,
      startup_threshold = 2000,
      network_charge_bandwidth = 200,
      passive_lost = 0,
    },

    work = function (pos, node, available_energy, work_rate, dtime, ot)
      return 0
    end,
  },

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
  },

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)

    local inv = meta:get_inventory()

    -- It can program up to 16 devices at once
    inv:set_size("input_items", 16)
    inv:set_size("processing_items", 16)
    inv:set_size("output_items", 16)

    cluster_devices:schedule_add_node(pos, node)
    cluster_energy:schedule_add_node(pos, node)
    data_network:add_node(pos, node)
  end,

  after_destruct = function (pos, node)
    cluster_devices:schedule_remove_node(pos, node)
    cluster_energy:schedule_remove_node(pos, node)
    data_network:remove_node(pos, node)
  end,

  on_dig = function (pos, node, digger)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()

    if inv:is_empty("input_items") and
       inv:is_empty("processing_items") and
       inv:is_empty("output_items") then
      return minetest.node_dig(pos, node, digger)
    end

    return false
  end,

  refresh_infotext = function (pos)
    local meta = minetest.get_meta(pos)

    local infotext =
      cluster_devices:get_node_infotext(pos) .. "\n" ..
      cluster_energy:get_node_infotext(pos) .. " (" .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. ")" .. "\n" ..
      data_network:get_infotext(pos)

    meta:set_string("infotext", infotext)
  end,

  on_rightclick = function (pos, node, clicker, item_stack, pointed_thing)
    local formspec_name = "yatm_security:programmers_table:" .. minetest.pos_to_string(pos)
    local assigns = { pos = pos, node = node }

    yatm_core.bind_on_player_receive_fields(clicker, formspec_name,
                                            assigns,
                                            handle_receive_fields)

    minetest.show_formspec(
      clicker:get_player_name(),
      formspec_name,
      get_formspec(pos, assigns)
    )
  end,
}, {
  error = {
    tiles = {
      "yatm_programmers_table_top.error.png",
      "yatm_programmers_table_bottom.error.png",
      "yatm_programmers_table_side.error.png",
      "yatm_programmers_table_side.error.png",
      "yatm_programmers_table_side.error.png",
      "yatm_programmers_table_side.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_programmers_table_top.on.png",
      "yatm_programmers_table_bottom.on.png",
      "yatm_programmers_table_side.on.png",
      "yatm_programmers_table_side.on.png",
      "yatm_programmers_table_side.on.png",
      "yatm_programmers_table_side.on.png",
    },
  },
})
