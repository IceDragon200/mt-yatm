local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)
local Network = assert(yatm.network)

local function computer_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    "Network ID: " .. Network.to_infotext(meta) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function computer_data_interface(pos, node, port, value)
end

local computer_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_oku:computer_error",
    error = "yatm_oku:computer_error",
    off = "yatm_oku:computer_off",
    on = "yatm_oku:computer_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 0,
    startup_threshold = 100,
    network_charge_bandwidth = 500,
  }
}

function computer_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  local energy_consumed = 0
  local nodedef = minetest.registered_nodes[node.name]
  -- TODO
  return energy_consumed
end

local groups = {
  cracky = 1,
  yatm_data_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  description = "Computer",
  groups = groups,
  drop = computer_yatm_network.states.off,
  tiles = {
    "yatm_computer_top.off.png",
    "yatm_computer_bottom.png",
    "yatm_computer_side.off.png",
    "yatm_computer_side.off.png^[transformFX",
    "yatm_computer_back.png",
    "yatm_computer_front.off.png"
  },
  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = computer_yatm_network,

  data_network_device = {
    color = color_basename,
    type = "device",
  },

  data_interface = computer_data_interface,

  refresh_infotext = computer_refresh_infotext,
}, {
  error = {
    tiles = {
      "yatm_computer_top.error.png",
      "yatm_computer_bottom.png",
      "yatm_computer_side.error.png",
      "yatm_computer_side.error.png^[transformFX",
      "yatm_computer_back.png",
      "yatm_computer_front.error.png"
    },
  },
  on = {
    tiles = {
      "yatm_computer_top.on.png",
      "yatm_computer_bottom.png",
      "yatm_computer_side.on.png",
      "yatm_computer_side.on.png^[transformFX",
      "yatm_computer_back.png",
      {
        name = "yatm_computer_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      }
    },
  }
})
