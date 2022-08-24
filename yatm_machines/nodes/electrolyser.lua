--
-- Electrolyser
--
--   Splits fluids into different gases.
--
local mod = yatm_machines
local fspec = assert(foundation.com.formspec.api)
local yatm_fspec = assert(yatm.formspec)
local Vector3 = assert(foundation.com.Vector3)
local player_service = assert(nokore.player_service)

local yatm_network = {
  kind = "machine",
  groups = {
    machine_worker = 1,
    energy_consumer = 1,
  },
  default_state = "off",
  states = {
    conflict = "yatm_machines:electrolyser_error",
    error = "yatm_machines:electrolyser_error",
    off = "yatm_machines:electrolyser_off",
    on = "yatm_machines:electrolyser_on",
  },
  energy = {
    capacity = 4000,
    passive_lost = 10,
    startup_threshold = 200,
    network_charge_bandwidth = 100,
  }
}

function yatm_network:work(ctx)
  return 0
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
  return "yatm_machines:electrolyser:"..Vector3.to_string(pos)
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
  codex_entry_id = mod:make_name("electrolyser"),

  basename = mod:make_name("electrolyser"),

  description = mod.S("Electrolyser"),

  groups = {
    cracky = 1,
  },
  tiles = {
    "yatm_electrolyser_top.off.png",
    "yatm_electrolyser_bottom.png",
    "yatm_electrolyser_side.off.png",
    "yatm_electrolyser_side.off.png^[transformFX",
    "yatm_electrolyser_back.png",
    "yatm_electrolyser_front.off.png",
  },
  paramtype = "none",
  paramtype2 = "facedir",
  yatm_network = yatm_network,

  on_rightclick = on_rightclick,
}, {
  error = {
    tiles = {
      "yatm_electrolyser_top.error.png",
      "yatm_electrolyser_bottom.png",
      "yatm_electrolyser_side.error.png",
      "yatm_electrolyser_side.error.png^[transformFX",
      "yatm_electrolyser_back.png",
      "yatm_electrolyser_front.error.png",
    },
  },
  on = {
    tiles = {
      "yatm_electrolyser_top.on.png",
      "yatm_electrolyser_bottom.png",
      "yatm_electrolyser_side.on.png",
      "yatm_electrolyser_side.on.png^[transformFX",
      "yatm_electrolyser_back.png",
      {
        name = "yatm_electrolyser_front.on.png",
        animation = {
          type = "vertical_frames",
          aspect_w = 16,
          aspect_h = 16,
          length = 1
        },
      },
    },
  }
})
