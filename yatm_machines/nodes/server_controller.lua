--
-- Not sure what I'm going to do with this, but it looks pretty cute.
--
local cluster_devices = assert(yatm.cluster.devices)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)

local function server_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function server_controller_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  local node = minetest.get_node(pos)
  data_network:add_node(pos, node)
  yatm.devices.device_after_place_node(pos, node)
end

local function server_controller_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function server_controller_after_destruct(pos, old_node)
  data_network:unregister_member(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local server_controller_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
  }
}

local server_controller_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:server_controller_error",
    error = "yatm_machines:server_controller_error",
    off = "yatm_machines:server_controller_off",
    on = "yatm_machines:server_controller_on",
  },
  energy = {
    capacity = 2000,
    network_charge_bandwidth = 100,
    passive_lost = 5,
    startup_threshold = 20,
  }
}

function server_controller_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  data_network:send_value(pos, node, 1, 10)
  return 0
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:server_controller",

  description = "Server Controller",

  groups = {
    cracky = 1,
    yatm_data_device = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  drop = server_controller_yatm_network.states.off,

  tiles = {
    "yatm_server_controller_top.off.png",
    "yatm_server_controller_bottom.png",
    "yatm_server_controller_side.off.png",
    "yatm_server_controller_side.off.png^[transformFX",
    "yatm_server_controller_back.off.png",
    "yatm_server_controller_front.off.png",
  },
  use_texture_alpha = "opaque",
  drawtype = "nodebox",
  node_box = server_controller_node_box,

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = server_controller_yatm_network,

  data_network_device = {
    type = "device",
  },

  refresh_infotext = server_controller_refresh_infotext,

  after_place_node = server_controller_after_place_node,
  on_destruct = server_controller_on_destruct,
  after_destruct = server_controller_after_destruct,
}, {
  error = {
    tiles = {
      "yatm_server_controller_top.error.png",
      "yatm_server_controller_bottom.png",
      "yatm_server_controller_side.error.png",
      "yatm_server_controller_side.error.png^[transformFX",
      "yatm_server_controller_back.error.png",
      "yatm_server_controller_front.error.png",
    },
    use_texture_alpha = "opaque",
  },
  on = {
    tiles = {
      "yatm_server_controller_top.on.png",
      "yatm_server_controller_bottom.png",
      "yatm_server_controller_side.on.png",
      "yatm_server_controller_side.on.png^[transformFX",
      "yatm_server_controller_back.on.png",
      {
        name = "yatm_server_controller_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1.0
        },
      }
    },
    use_texture_alpha = "opaque",
  },
})
