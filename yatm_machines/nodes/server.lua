--
-- Servers provide a means to automate certain tasks in a network (i.e. crafting)
--
local mod = yatm_machines
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local device_get_node_infotext = assert(cluster_devices.get_node_infotext)
local energy_get_node_infotext = assert(cluster_energy.get_node_infotext)
local energy_meta_to_infotext = assert(Energy.meta_to_infotext)
local data_network_get_infotext = assert(data_network.get_infotext)

local ENERGY_BUFFER_KEY = yatm.devices.ENERGY_BUFFER_KEY

local function server_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)

  local infotext =
    device_get_node_infotext(cluster_devices, pos) .. "\n" ..
    energy_get_node_infotext(cluster_energy, pos) .. "\n" ..
    "Energy: " .. energy_meta_to_infotext(meta, ENERGY_BUFFER_KEY) .. "\n" ..
    data_network_get_infotext(data_network, pos)

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
    startup_threshold = 100,
  }
}

function server_yatm_network:work(ctx)
  local dtime = ctx.dtime
  --data_network:mark_ready_to_receive(pos, 1)
  --data_network:mark_ready_to_receive(pos, 2)
  --data_network:mark_ready_to_receive(pos, 3)
  --data_network:mark_ready_to_receive(pos, 4)
  --data_network:mark_ready_to_receive(pos, 5)
  return 50 * dtime
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine" }, function (loc, rect)
    if loc == "main_body" then
      return yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          rect.h,
          meta,
          yatm.devices.ENERGY_BUFFER_KEY,
          yatm.devices.get_energy_capacity(pos, state.node)
        )
    elseif loc == "footer" then
      return ""
    end
    return ""
  end)
end

local function on_receive_fields(player, form_name, fields, state)
  return false, nil
end

local function make_formspec_name(pos)
  return "yatm_machines:server:"..Vector3.to_string(pos)
end

local function on_refresh_timer(player_name, form_name, state)
  local player = player_service:get_player_by_name(player_name)
  return {
    {
      type = "refresh_formspec",
      value = render_formspec(state.pos, player, state),
    }
  }
end

local function on_rightclick(pos, node, user)
  local state = {
    pos = pos,
    node = node,
  }
  local formspec = render_formspec(pos, user, state)

  nokore.formspec_bindings:show_formspec(
    user:get_player_name(),
    make_formspec_name(pos),
    formspec,
    {
      state = state,
      on_receive_fields = on_receive_fields,
      timers = {
        -- routinely update the formspec
        refresh = {
          every = 1,
          action = on_refresh_timer,
        },
      },
    }
  )
end

yatm.devices.register_stateful_network_device({
  basename = "yatm_machines:server",

  codex_entry_id = "yatm_machines:server",

  description = mod.S("Server"),

  groups = {
    cracky = 1,
    yatm_data_device = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  drop = server_yatm_network.states.off,

  use_texture_alpha = "opaque",
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

  on_rightclick = on_rightclick,
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
