--
-- Not sure what I'm going to do with this, but it looks pretty cute.
--
local mod = yatm_machines
local cluster_devices = assert(yatm.cluster.devices)
local data_network = assert(yatm.data_network)
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local energy_fspec = assert(yatm.energy.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local function server_controller_refresh_infotext(pos, node)
  local meta = minetest.get_meta(pos)
  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    "Energy: " .. Energy.meta_to_infotext(meta, yatm.devices.ENERGY_BUFFER_KEY) .. "\n" ..
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
    startup_threshold = 50,
  }
}

function server_controller_yatm_network:work(ctx)
  local pos = ctx.pos
  local node = ctx.node

  data_network:send_value(pos, node, 1, 10)
  return 0
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "dscs" }, function (loc, rect)
    if loc == "main_body" then
      return energy_fspec.render_meta_energy_gauge(
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
  return "yatm_machines:server_controller:"..Vector3.to_string(pos)
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
  basename = "yatm_machines:server_controller",

  codex_entry_id = "yatm_machines:server_controller",

  description = mod.S("Server Controller"),

  groups = {
    cracky = 1,
    yatm_data_device = 1,
    yatm_network_device = 1,
    yatm_energy_device = 1,
  },

  drop = server_controller_yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_server_controller_top.off.png",
    "yatm_server_controller_bottom.png",
    "yatm_server_controller_side.off.png",
    "yatm_server_controller_side.off.png^[transformFX",
    "yatm_server_controller_back.off.png",
    "yatm_server_controller_front.off.png",
  },

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

  on_rightclick = on_rightclick,
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
