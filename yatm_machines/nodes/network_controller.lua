local mod = yatm_machines
local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)
local Vector3 = assert(foundation.com.Vector3)
local Energy = assert(yatm.energy)

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos)

  meta:set_string("infotext", infotext)
end

local yatm_network = {
  kind = "controller",
  groups = {
    device_controller = 1,
    energy_consumer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_machines:network_controller_error",
    error = "yatm_machines:network_controller_error",
    on = "yatm_machines:network_controller_on",
    off = "yatm_machines:network_controller_off",
  },

  energy = {
    capacity = 4000,
    passive_lost = 20,
    network_charge_bandwidth = 200,
    startup_threshold = 100,
  },
}

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
  return "yatm_machines:network_controller:"..Vector3.to_string(pos)
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

local groups = {
  cracky = 1,
  yatm_network_device = 1,
  yatm_energy_device = 1,
}

yatm.devices.register_stateful_network_device({
  codex_entry_id = mod:make_name("network_controller"),

  basename = mod:make_name("network_controller"),

  description = mod.S("Network Controller"),

  groups = groups,

  drop = yatm_network.states.off,

  sounds = yatm.node_sounds:build("metal"),

  tiles = {
    "yatm_network_controller_top.off.png",
    "yatm_network_controller_bottom.png",
    "yatm_network_controller_side.off.png",
    "yatm_network_controller_side.off.png^[transformFX",
    "yatm_network_controller_back.off.png",
    "yatm_network_controller_front.off.png",
  },

  paramtype = "none",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_network_controller_top.error.png",
      "yatm_network_controller_bottom.png",
      "yatm_network_controller_side.error.png",
      "yatm_network_controller_side.error.png^[transformFX",
      "yatm_network_controller_back.error.png",
      "yatm_network_controller_front.error.png",
    },
  },
  on = {
    tiles = {
      {
        name = "yatm_network_controller_top.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_network_controller_bottom.png",
      {
        name = "yatm_network_controller_side.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      {
        name = "yatm_network_controller_side.on.png^[transformFX",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      },
      "yatm_network_controller_back.on.png",
      "yatm_network_controller_front.on.png",
    }
  },
})
