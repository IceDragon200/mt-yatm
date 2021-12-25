local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local cluster_thermal = assert(yatm.cluster.thermal)
local Energy = assert(yatm.energy)

local heater_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
    heat_producer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_foundry:electric_heater_error",
    error = "yatm_foundry:electric_heater_error",
    off = "yatm_foundry:electric_heater_off",
    on = "yatm_foundry:electric_heater_on",
  },
  energy = {
    passive_lost = 0,
    capacity = 32000,
    network_charge_bandwidth = 500,
    startup_threshold = 1000,
  },
}

local HEAT_MAX = 1600

function heater_yatm_network:work(ctx)
  local pos = ctx.pos
  local meta = ctx.meta
  local node = ctx.node
  local dtime = ctx.dtime

  local heat = meta:get_float("heat")
  local new_heat = math.min(heat + 10 * dtime, HEAT_MAX)
  meta:set_float("heat", new_heat)
  -- due to precision issues with floating point numbers,
  -- Just check if the old heat is less than the new one
  if heat < new_heat then
    yatm.queue_refresh_infotext(pos, node)
  end

  -- heaters devour energy like no tomorrow
  return math.floor(100 * ctx.dtime)
end

local function electric_heater_refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  -- We only really care about the integral heat, it's only a float because of the dtime.
  local heat = math.floor(meta:get_float("heat"))

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    cluster_thermal:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    "Heat: " .. heat .. " / " .. HEAT_MAX

  meta:set_string("infotext", infotext)
end

local groups = {
  cracky = 1,
  heater_device = 1,
  yatm_energy_device = 1
}

yatm.devices.register_stateful_network_device({
  basename = "yatm_foundry:electric_heater",

  description = "Electric Heater",

  codex_entry_id = "yatm_foundry:electric_heater",

  groups = groups,

  drop = heater_yatm_network.states.off,

  tiles = {
    "yatm_heater_top.off.png",
    "yatm_heater_bottom.png",
    "yatm_heater_side.off.png",
    "yatm_heater_side.off.png^[transformFX",
    "yatm_heater_back.off.png",
    "yatm_heater_front.off.png"
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = heater_yatm_network,

  on_construct = function (pos)
    local node = minetest.get_node(pos)
    yatm.devices.device_on_construct(pos)
    cluster_thermal:schedule_add_node(pos, node)
  end,

  refresh_infotext = electric_heater_refresh_infotext,

  thermal_interface = {
    groups = {
      heater = 1,
      thermal_producer = 1,
      updatable = 1,
    },

    get_heat = function (self, pos, node)
      local meta = minetest.get_meta(pos)
      return meta:get_float("heat")
    end,

    update = function (self, pos, node, dtime)
      -- because devices don't 'work' when their offline, the thermal system will handle the heat dissipation
      if node.name ~= "yatm_foundry:electric_heater_on" then
        local meta = minetest.get_meta(pos)
        local heat = meta:get_float("heat")
        heat = math.max(heat - 5 * dtime, 0)
        meta:set_float("heat", heat)
      end
    end,
  },
}, {
  error = {
    tiles = {
      "yatm_heater_top.error.png",
      "yatm_heater_bottom.png",
      "yatm_heater_side.error.png",
      "yatm_heater_side.error.png^[transformFX",
      "yatm_heater_back.error.png",
      "yatm_heater_front.error.png"
    },
  },

  on = {
    tiles = {
      "yatm_heater_top.on.png",
      "yatm_heater_bottom.png",
      "yatm_heater_side.on.png",
      "yatm_heater_side.on.png^[transformFX",
      "yatm_heater_back.on.png",
      "yatm_heater_front.on.png"
    },
    light_source = 7,
  },
})
