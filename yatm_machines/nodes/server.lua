--
-- Servers provide a means to automate certain tasks in a network (i.e. crafting)
--
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)

local function server_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
    data_network:get_infotext(pos)

  meta:set_string("infotext", infotext)
end

local function server_after_place_node(pos, _placer, _item_stack, _pointed_thing)
  local node = minetest.get_node(pos)
  data_network:add_node(pos, node)
  yatm.devices.device_after_place_node(pos, node)
end

local function server_on_destruct(pos)
  yatm.devices.device_on_destruct(pos)
end

local function server_after_destruct(pos, old_node)
  data_network:unregister_member(pos, old_node)
  yatm.devices.device_after_destruct(pos, old_node)
end

local server_yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:server_error",
    error = "yatm_machines:server_error",
    off = "yatm_machines:server_off",
    on = "yatm_machines:server_on",
  },
  energy = {
    capacity = 16000,
    network_charge_bandwidth = 200,
    passive_lost = 0,
    startup_threshold = 400,
  }
}

function server_yatm_network.work(pos, node, energy_available, work_rate, dtime, ot)
  --data_network:mark_ready_to_receive(pos, 1)
  --data_network:mark_ready_to_receive(pos, 2)
  --data_network:mark_ready_to_receive(pos, 3)
  --data_network:mark_ready_to_receive(pos, 4)
  --data_network:mark_ready_to_receive(pos, 5)
  return 50
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:server",

  description = "Server",

  groups = {
    cracky = 1,
    yatm_data_device = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  drop = server_yatm_network.states.off,

  tiles = {
    "yatm_server_top.off.png",
    "yatm_server_bottom.png",
    "yatm_server_side.png",
    "yatm_server_side.png^[transformFX",
    "yatm_server_back.off.png",
    "yatm_server_front.off.png",
  },

  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-0.4375, -0.5, -0.4375, 0.4375, 0.3125, 0.4375}, -- InnerCore
      {-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- Rack4
      {-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- Rack3
      {-0.5, -0.1875, -0.5, 0.5, 0, 0.5}, -- Rack2
      {-0.5, -0.4375, -0.5, 0.5, -0.25, 0.5}, -- Rack1
      {-0.4375, -0.4375, 0.4375, 0.0625, 0.3125, 0.5}, -- BackPanel
    }
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = server_yatm_network,

  data_network_device = {
    type = "device",
  },
  data_interface = {
    on_load = function (self, pos, node)
      --
    end,

    receive_pdu = function (self, pos, node, dir, port, value)
      print("received a pdu", minetest.pos_to_string(pos), node.name, dir, port, value)
    end,
  },
  refresh_infotext = server_refresh_infotext,

  after_place_node = server_after_place_node,
  on_destruct = server_on_destruct,
  after_destruct = server_after_destruct,
}, {
  error = {
    tiles = {
      "yatm_server_top.error.png",
      "yatm_server_bottom.png",
      "yatm_server_side.png",
      "yatm_server_side.png^[transformFX",
      "yatm_server_back.error.png",
      "yatm_server_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_server_top.on.png",
      "yatm_server_bottom.png",
      "yatm_server_side.png",
      "yatm_server_side.png^[transformFX",
      -- "yatm_server_back.off.png",
      {
        name = "yatm_server_back.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      -- "yatm_server_front.off.png"
      {
        name = "yatm_server_front.on.png",
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
