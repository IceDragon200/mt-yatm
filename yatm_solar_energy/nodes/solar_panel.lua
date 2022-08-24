local mod = yatm_solar_energy
local Energy = assert(yatm.energy)
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local player_service = assert(nokore.player_service)

local cluster_devices = assert(yatm.cluster.devices)
local cluster_energy = assert(yatm.cluster.energy)

local yatm_network = {
  kind = "energy_producer",
  groups = {
    device_controller = 3,
    energy_producer = 1,
  },

  default_state = "off",
  states = {
    conflict = "yatm_solar_energy:solar_panel_error",
    error = "yatm_solar_energy:solar_panel_error",
    off = "yatm_solar_energy:solar_panel_off",
    on = "yatm_solar_energy:solar_panel_on",
  },

  energy = {
    capacity = 16000,
  }
}

function yatm_network.energy.produce_energy(pos, node, dtime, ot)
  local meta = minetest.get_meta(pos)
  local light = minetest.get_natural_light(pos, nil)
  local energy = 0
  if light > 5 then
    energy = light * 3 * dtime
  end
  yatm.queue_refresh_infotext(pos, node)
  meta:set_int("last_produced_energy", energy)
  return energy
end

local function refresh_infotext(pos)
  local meta = minetest.get_meta(pos)

  local last_produced_energy = meta:get_int("last_produced_energy")

  local infotext =
    cluster_devices:get_node_infotext(pos) .. "\n" ..
    cluster_energy:get_node_infotext(pos) .. "[+ " .. last_produced_energy .. "]"

  meta:set_string("infotext", infotext)
end

local function render_formspec(pos, user, state)
  local spos = pos.x .. "," .. pos.y .. "," .. pos.z
  local node_inv_name = "nodemeta:" .. spos
  local cio = fspec.calc_inventory_offset
  local cis = fspec.calc_inventory_size
  local meta = minetest.get_meta(pos)

  return yatm.formspec_render_split_inv_panel(user, nil, 4, { bg = "machine_electric" }, function (loc, rect)
    if loc == "main_body" then
      return yatm_fspec.render_meta_energy_gauge(
          rect.x + rect.w - cio(1),
          rect.y,
          1,
          cis(4),
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
  return "yatm_solar_energy:solar_panel:"..Vector3.to_string(pos)
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

local solar_panel_nodebox = {
  type = "fixed",
  fixed = {
    {-0.5, -0.5, -0.5, 0.5, (4 / 16) - 0.5, 0.5},
  },
}

yatm.devices.register_stateful_network_device({
  basename = mod:make_name("solar_panel"),

  description = mod.S("Solar Panel"),

  codex_entry_id = mod:make_name("solar_panel"),

  groups = {
    cracky = 1,
    yatm_energy_device = 1,
  },

  drop = yatm_network.states.off,

  sounds = yatm.node_sounds:build("glass"),

  tiles = {
    "yatm_solar_panel_top.off.png",
    "yatm_solar_panel_bottom.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
    "yatm_solar_panel_side.off.png",
  },
  use_texture_alpha = "opaque",

  drawtype = "nodebox",
  node_box = solar_panel_nodebox,

  paramtype = "light",
  paramtype2 = "facedir",

  yatm_network = yatm_network,

  refresh_infotext = refresh_infotext,
}, {
  on = {
    tiles = {
      "yatm_solar_panel_top.on.png",
      "yatm_solar_panel_bottom.on.png",
      "yatm_solar_panel_side.on.png",
      "yatm_solar_panel_side.on.png",
      "yatm_solar_panel_side.on.png",
      "yatm_solar_panel_side.on.png",
    },
    use_texture_alpha = "opaque",
  },
  error = {
    tiles = {
      "yatm_solar_panel_top.error.png",
      "yatm_solar_panel_bottom.error.png",
      "yatm_solar_panel_side.error.png",
      "yatm_solar_panel_side.error.png",
      "yatm_solar_panel_side.error.png",
      "yatm_solar_panel_side.error.png",
    },
    use_texture_alpha = "opaque",
  }
})
