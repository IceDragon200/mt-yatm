local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local Energy = assert(yatm.energy)

local function get_electric_furnace_formspec(pos, user)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local formspec =
    "size[8,9]" ..
    yatm.formspec_bg_for_player(user:get_player_name(), "machine_heated") ..
    "list[current_player;main;0,4.85;8,1;]" ..
    "list[current_player;main;0,6.08;8,3;8]"

  return formspec
end

local function electric_furnace_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  -- We only really care about the integral heat, it's only a float because of the dtime.
  local heat = math.floor(meta:get_float("heat"))

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY)

  meta:set_string("infotext", infotext)
end

local electric_furnace_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    item_consumer = 1,
    item_producer = 1,
    heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_furnace_error",
    error = "yatm_foundry:electric_furnace_error",
    off = "yatm_foundry:electric_furnace_off",
    on = "yatm_foundry:electric_furnace_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 4000,
    network_charge_bandwidth = 1000,
    startup_threshold = 400,
  },
}

function electric_furnace_yatm_network.work(pos, node, available_energy, work_rate, dtime, ot)
  return 0
end

local groups = {
  cracky = 1,
  item_interface_in = 1,
  item_interface_out = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_foundry:electric_furnace",

  description = "Electric Furnace",

  codex_entry_id = "yatm_foundry:electric_furnace",

  groups = groups,

  drop = electric_furnace_yatm_network.states.off,

  tiles = {
    "yatm_electric_furnace_top.off.png",
    "yatm_electric_furnace_bottom.png",
    "yatm_electric_furnace_side.off.png",
    "yatm_electric_furnace_side.off.png^[transformFX",
    "yatm_electric_furnace_back.png",
    "yatm_electric_furnace_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = electric_furnace_yatm_network,

  refresh_infotext = electric_furnace_refresh_infotext,

  on_construct = function (pos)
    yatm.devices.device_on_construct(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    --inv:set_size("input_slot", 1)
    --inv:set_size("processing_slot", 1)
  end,

  on_rightclick = function (pos, node, user)
    minetest.show_formspec(
      user:get_player_name(),
      "yatm_foundry:electric_furnace",
      get_electric_furnace_formspec(pos, user)
    )
  end,
}, {
  error = {
    tiles = {
      "yatm_electric_furnace_top.error.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.error.png",
      "yatm_electric_furnace_side.error.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_electric_furnace_top.on.png",
      "yatm_electric_furnace_bottom.png",
      "yatm_electric_furnace_side.on.png",
      "yatm_electric_furnace_side.on.png^[transformFX",
      "yatm_electric_furnace_back.png",
      "yatm_electric_furnace_front.on.png"
    },
    light_source = 7,
  },
})

