local mod = yatm_machines
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local server_rack_node_box = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- NodeBox1
  }
}

local yatm_network = {
  kind = "machine",
  groups = {
    machine = 1,
    energy_consumer = 1,
    dscs_server = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:server_rack_error",
    error = "yatm_machines:server_rack_error",
    off = "yatm_machines:server_rack_off",
    on = "yatm_machines:server_rack_on",
  },
  energy = {
    passive_lost = 10,
    capacity = 4000,
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

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "dscs" }, function (loc, rect)
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
  return "yatm_machines:server_rack:"..Vector3.to_string(pos)
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
  basename = "yatm_machines:server_rack",

  description = "Server Rack",

  groups = {
    cracky = nokore.dig_class("copper"),
  },

  drop = yatm_network.states.off,

  use_texture_alpha = "opaque",
  tiles = {
    "yatm_server_rack_top.off.png",
    "yatm_server_rack_bottom.png",
    "yatm_server_rack_side.off.png",
    "yatm_server_rack_side.off.png^[transformFX",
    "yatm_server_rack_back.off.png",
    "yatm_server_rack_front.off.png",
  },
  drawtype = "nodebox",
  node_box = server_rack_node_box,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_server_rack_top.error.png",
      "yatm_server_rack_bottom.png",
      "yatm_server_rack_side.error.png",
      "yatm_server_rack_side.error.png^[transformFX",
      "yatm_server_rack_back.error.png",
      "yatm_server_rack_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_server_rack_top.on.png",
      "yatm_server_rack_bottom.png",
      "yatm_server_rack_side.on.png",
      "yatm_server_rack_side.on.png^[transformFX",
      "yatm_server_rack_back.on.png",
      {
        name = "yatm_server_rack_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 2.0
        },
      }
    },
  }
})
